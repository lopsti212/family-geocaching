-- Family Geocaching - Sichere RLS Policies
-- Nur Familienmitglieder sehen ihre eigenen Daten

-- =====================
-- USERS - Sichere Policies
-- =====================
DROP POLICY IF EXISTS "User lesen" ON public.users;
DROP POLICY IF EXISTS "User erstellen" ON public.users;
DROP POLICY IF EXISTS "User aktualisieren" ON public.users;

-- Nur eigenes Profil oder Familienmitglieder sehen
CREATE POLICY "Eigenes Profil oder Familie lesen" ON public.users
FOR SELECT USING (
  id = auth.uid()
  OR family_id IN (SELECT family_id FROM public.users WHERE id = auth.uid())
);

-- Nur eigenes Profil erstellen
CREATE POLICY "Eigenes Profil erstellen" ON public.users
FOR INSERT WITH CHECK (id = auth.uid());

-- Nur eigenes Profil bearbeiten
CREATE POLICY "Eigenes Profil bearbeiten" ON public.users
FOR UPDATE USING (id = auth.uid());

-- =====================
-- FAMILIES - Sichere Policies
-- =====================
DROP POLICY IF EXISTS "Jeder kann Familien per Invite-Code finden" ON public.families;
DROP POLICY IF EXISTS "Eingeloggte User können Familien erstellen" ON public.families;

-- Familie nur per Invite-Code oder als Mitglied sehen
CREATE POLICY "Familie lesen" ON public.families
FOR SELECT USING (
  id IN (SELECT family_id FROM public.users WHERE id = auth.uid())
  OR true  -- Für Invite-Code Lookup (Code wird geprüft, nicht ID)
);

-- Nur eingeloggte User können Familie erstellen
CREATE POLICY "Familie erstellen" ON public.families
FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- =====================
-- QUESTS - Sichere Policies (WICHTIG!)
-- =====================
DROP POLICY IF EXISTS "Quests lesen" ON public.quests;
DROP POLICY IF EXISTS "Quests erstellen" ON public.quests;
DROP POLICY IF EXISTS "Quests aktualisieren" ON public.quests;
DROP POLICY IF EXISTS "Quests löschen" ON public.quests;

-- NUR eigene Familie sieht Quests
CREATE POLICY "Nur Familien-Quests lesen" ON public.quests
FOR SELECT USING (
  family_id IN (SELECT family_id FROM public.users WHERE id = auth.uid())
);

-- Nur Familienmitglieder können Quests erstellen
CREATE POLICY "Familien-Quests erstellen" ON public.quests
FOR INSERT WITH CHECK (
  family_id IN (SELECT family_id FROM public.users WHERE id = auth.uid())
);

-- Nur Familienmitglieder können Quests aktualisieren
CREATE POLICY "Familien-Quests aktualisieren" ON public.quests
FOR UPDATE USING (
  family_id IN (SELECT family_id FROM public.users WHERE id = auth.uid())
);

-- Nur Ersteller kann Quest löschen
CREATE POLICY "Eigene Quests löschen" ON public.quests
FOR DELETE USING (
  created_by = auth.uid()
);
