/*
  # Fix Client Collaborators Schema

  1. Changes
    - Remove collaborator_ids column if it exists
    - Add indexes for better performance
    - Update client_collaborators table constraints

  2. Security
    - Enable RLS on client_collaborators table
    - Add policies for authenticated users
*/

-- Remove collaborator_ids if it exists (it shouldn't be in the clients table)
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'clients' 
    AND column_name = 'collaborator_ids'
  ) THEN
    ALTER TABLE clients DROP COLUMN collaborator_ids;
  END IF;
END $$;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_client_collaborators_client_id ON client_collaborators(client_id);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_collaborator_id ON client_collaborators(collaborator_id);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_service_date ON client_collaborators(service_date);

-- Enable RLS
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;

-- Add policies
CREATE POLICY "Authenticated users can manage client collaborators"
  ON client_collaborators
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);