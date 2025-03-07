import React from 'react';

interface Column {
  name: string;
  description: string;
}

interface ColumnSelectorProps {
  columns: Column[];
  selectedColumns: string[];
  onChange: (columns: string[]) => void;
}

export function ColumnSelector({ columns, selectedColumns, onChange }: ColumnSelectorProps) {
  const handleToggle = (columnName: string) => {
    const newSelection = selectedColumns.includes(columnName)
      ? selectedColumns.filter(col => col !== columnName)
      : [...selectedColumns, columnName];
    onChange(newSelection);
  };

  return (
    <div className="space-y-2">
      <div className="flex flex-wrap gap-2">
        {columns.map((column) => (
          <label
            key={column.name}
            className="flex items-center gap-2 bg-secondary/50 px-3 py-1.5 rounded-md cursor-pointer hover:bg-secondary/70 transition-colors"
          >
            <input
              type="checkbox"
              checked={selectedColumns.includes(column.name)}
              onChange={() => handleToggle(column.name)}
              className="rounded border-input"
            />
            <span className="text-sm font-medium">{column.name}</span>
          </label>
        ))}
      </div>
      <p className="text-sm text-muted-foreground">
        Selecione as colunas que deseja incluir na resposta da API
      </p>
    </div>
  );
}