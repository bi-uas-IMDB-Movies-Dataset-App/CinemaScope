-- Enable admin CRUD access for fact_movies using profile role
-- Run this after cinemascope_supabase.sql

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.id = auth.uid()
      AND lower(p.role) = 'admin'
  );
$$;

DROP POLICY IF EXISTS "Admins can insert fact_movies" ON public.fact_movies;
DROP POLICY IF EXISTS "Admins can update fact_movies" ON public.fact_movies;
DROP POLICY IF EXISTS "Admins can delete fact_movies" ON public.fact_movies;

CREATE POLICY "Admins can insert fact_movies"
ON public.fact_movies
FOR INSERT
WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update fact_movies"
ON public.fact_movies
FOR UPDATE
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "Admins can delete fact_movies"
ON public.fact_movies
FOR DELETE
USING (public.is_admin());

-- Profiles policies for admin user-management page
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;

CREATE POLICY "Admins can view all profiles"
ON public.profiles
FOR SELECT
USING (public.is_admin());

CREATE POLICY "Admins can update all profiles"
ON public.profiles
FOR UPDATE
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Promote a user to admin (replace with your email):
-- UPDATE public.profiles SET role = 'admin' WHERE email = 'you@example.com';
