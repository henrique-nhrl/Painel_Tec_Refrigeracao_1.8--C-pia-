import React from 'react';

interface ApiMethodSelectorProps {
  value: string;
  onChange: (method: string) => void;
}

export function ApiMethodSelector({ value, onChange }: ApiMethodSelectorProps) {
  const methods = ['GET', 'POST', 'PUT', 'DELETE'];

  return (
    <div className="flex gap-2">
      {methods.map((method) => (
        <button
          key={method}
          onClick={() => onChange(method)}
          className={`px-3 py-1 rounded-md text-sm font-medium transition-colors ${
            value === method
              ? 'bg-primary text-primary-foreground'
              : 'bg-secondary text-secondary-foreground hover:bg-secondary/90'
          }`}
        >
          {method}
        </button>
      ))}
    </div>
  );
}