/*
  # Fix client collaborators relationship

  1. Changes
    - Drop existing triggers to avoid conflicts
    - Update client_history structure
    - Create new function for logging changes
    - Add proper indexes for performance
    - Update RLS policies

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Drop existing triggers to avoid conflicts
DROP TRIGGER IF EXISTS client_changes_trigger ON clients;
DROP TRIGGER IF EXISTS log_client_collaborator_changes_trigger ON client_collaborators;

-- Update client_history structure
ALTER TABLE client_history 
DROP COLUMN IF EXISTS collaborators,
DROP COLUMN IF EXISTS client_collaborators;

ALTER TABLE client_history
ADD COLUMN collaborators jsonb DEFAULT '[]'::jsonb;

-- Create function for logging changes
CREATE OR REPLACE FUNCTION log_client_changes()
RETURNS trigger AS $$
DECLARE
  collaborators_data jsonb;
BEGIN
  -- Get current collaborators data
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', c.id,
      'name', c.name,
      'service_date', cc.service_date
    )
  )
  INTO collaborators_data
  FROM client_collaborators cc
  JOIN collaborators c ON c.id = cc.collaborator_id
  WHERE cc.client_id = NEW.id;

  -- Insert history record
  INSERT INTO client_history (
    client_id,
    user_id,
    changes,
    collaborators,
    created_at
  )
  VALUES (
    NEW.id,
    auth.uid(),
    jsonb_build_object(
      'before', to_jsonb(OLD),
      'after', to_jsonb(NEW)
    ),
    COALESCE(collaborators_data, '[]'::jsonb),
    now()
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for client changes
CREATE TRIGGER client_changes_trigger
  AFTER UPDATE ON clients
  FOR EACH ROW
  EXECUTE FUNCTION log_client_changes();

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_client_history_client_id ON client_history(client_id);
CREATE INDEX IF NOT EXISTS idx_client_history_created_at ON client_history(created_at);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_client_id ON client_collaborators(client_id);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_collaborator_id ON client_collaborators(collaborator_id);

-- Update RLS policies
ALTER TABLE client_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;

-- Policies for client_history
CREATE POLICY "View client history"
  ON client_history FOR SELECT
  TO authenticated
  USING (true);

-- Policies for client_collaborators
CREATE POLICY "Manage client collaborators"
  ON client_collaborators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);