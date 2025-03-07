/*
  # Fix client collaborators schema

  1. Changes
    - Drop existing client_collaborators table if exists
    - Create new client_collaborators table with proper relationships
    - Add necessary indexes for performance
    - Set up RLS policies

  2. Security
    - Enable RLS on client_collaborators table
    - Add policies for authenticated users
*/

-- Drop existing table if it exists
DROP TABLE IF EXISTS client_collaborators CASCADE;

-- Create client_collaborators table
CREATE TABLE client_collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  collaborator_id uuid REFERENCES collaborators(id) ON DELETE CASCADE,
  service_date date NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(client_id, collaborator_id, service_date)
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_client_collaborators_client ON client_collaborators(client_id);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_collaborator ON client_collaborators(collaborator_id);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_date ON client_collaborators(service_date);

-- Enable RLS
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Authenticated users can view client collaborators"
  ON client_collaborators FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can manage client collaborators"
  ON client_collaborators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Function to log changes
CREATE OR REPLACE FUNCTION log_client_collaborator_changes()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO logs (
      user_id,
      client_id,
      action
    ) VALUES (
      auth.uid(),
      NEW.client_id,
      'Colaborador associado ao atendimento'
    );
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO logs (
      user_id,
      client_id,
      action
    ) VALUES (
      auth.uid(),
      OLD.client_id,
      'Colaborador removido do atendimento'
    );
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for logging
CREATE TRIGGER log_client_collaborator_changes_trigger
  AFTER INSERT OR DELETE ON client_collaborators
  FOR EACH ROW
  EXECUTE FUNCTION log_client_collaborator_changes();