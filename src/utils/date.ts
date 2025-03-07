export function formatDateBR(date: string | Date): string {
  return new Date(date).toLocaleDateString('pt-BR');
}

export function calculateDaysRemaining(targetDate: string | Date): number {
  const target = new Date(targetDate);
  const today = new Date();
  const diffTime = target.getTime() - today.getTime();
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
}

export function formatDaysRemaining(days: number): string {
  if (days < 0) return 'Atrasado';
  if (days === 0) return 'Hoje';
  if (days === 1) return 'Amanhã';
  return `daqui a ${days} dias`;
}