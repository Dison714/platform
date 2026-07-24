export const metadata = { robots: { index: false, follow: false }, title: 'Deposit admin — internal' };
export const dynamic = 'force-dynamic';

// Раздел строится следующим шагом Configuration First (Шаг 2.3).
export default function DepositAdminPage() {
  return (
    <div style={{ maxWidth: 760, margin: '40px auto', padding: '0 20px', fontFamily: 'system-ui, sans-serif' }}>
      <h1 style={{ fontSize: 22 }}>Депозит</h1>
      <p style={{ color: '#888' }}>Раздел в разработке.</p>
    </div>
  );
}
