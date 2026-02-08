-- Family Geocaching - Supabase Schema
-- Führe dieses SQL in deinem Supabase SQL Editor aus

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Tabelle (erweitert die Auth-User)
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('parent', 'child')),
    family_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    xp INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1
);

-- Families Tabelle
CREATE TABLE public.families (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    created_by UUID NOT NULL REFERENCES public.users(id),
    invite_code TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Foreign Key für users.family_id
ALTER TABLE public.users
    ADD CONSTRAINT fk_users_family
    FOREIGN KEY (family_id) REFERENCES public.families(id);

-- Quests Tabelle
CREATE TABLE public.quests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    created_by UUID NOT NULL REFERENCES public.users(id),
    assigned_to UUID REFERENCES public.users(id),
    family_id UUID NOT NULL REFERENCES public.families(id),
    target_latitude DOUBLE PRECISION NOT NULL,
    target_longitude DOUBLE PRECISION NOT NULL,
    difficulty TEXT NOT NULL CHECK (difficulty IN ('level1', 'level2', 'level3', 'level4')),
    reward JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'inProgress', 'completed', 'expired')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    nfc_tag_id TEXT,
    hint_radius DOUBLE PRECISION
);

-- Indizes für bessere Performance
CREATE INDEX idx_users_family ON public.users(family_id);
CREATE INDEX idx_quests_family ON public.quests(family_id);
CREATE INDEX idx_quests_status ON public.quests(status);
CREATE INDEX idx_families_invite_code ON public.families(invite_code);

-- Row Level Security (RLS) aktivieren
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.families ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quests ENABLE ROW LEVEL SECURITY;

-- RLS Policies für Users
CREATE POLICY "Users können ihr eigenes Profil lesen"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users können Familienmitglieder sehen"
    ON public.users FOR SELECT
    USING (
        family_id IN (
            SELECT family_id FROM public.users WHERE id = auth.uid()
        )
    );

CREATE POLICY "Users können ihr Profil erstellen"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users können ihr Profil aktualisieren"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

-- RLS Policies für Families
CREATE POLICY "Familienmitglieder können Familie sehen"
    ON public.families FOR SELECT
    USING (
        id IN (SELECT family_id FROM public.users WHERE id = auth.uid())
    );

CREATE POLICY "Authentifizierte User können Familien erstellen"
    ON public.families FOR INSERT
    WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Familien können per Invite-Code gefunden werden"
    ON public.families FOR SELECT
    USING (true);  -- Für Invite-Code Lookup

-- RLS Policies für Quests
CREATE POLICY "Familienmitglieder können Quests sehen"
    ON public.quests FOR SELECT
    USING (
        family_id IN (SELECT family_id FROM public.users WHERE id = auth.uid())
    );

CREATE POLICY "Eltern können Quests erstellen"
    ON public.quests FOR INSERT
    WITH CHECK (
        auth.uid() = created_by
        AND EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'parent'
        )
    );

CREATE POLICY "Familienmitglieder können Quests aktualisieren"
    ON public.quests FOR UPDATE
    USING (
        family_id IN (SELECT family_id FROM public.users WHERE id = auth.uid())
    );

CREATE POLICY "Eltern können Quests löschen"
    ON public.quests FOR DELETE
    USING (
        created_by = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'parent'
        )
    );

-- Realtime aktivieren
ALTER PUBLICATION supabase_realtime ADD TABLE public.quests;
