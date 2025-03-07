-- Create a function to get all profiles (bypassing RLS)
CREATE OR REPLACE FUNCTION get_all_profiles()
RETURNS SETOF profiles
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT * FROM profiles ORDER BY created_at DESC;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_all_profiles() TO authenticated;

-- Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';