import { Teko, Poppins } from 'next/font/google';
import './globals.css';

// Шрифты бренда (эволюция bikebalirent.com): Teko — дисплейные заголовки,
// Poppins — текст/UI. Self-hosted через next/font (без внешних запросов в рантайме).
const teko = Teko({ subsets: ['latin'], weight: ['500', '600'], variable: '--font-teko', display: 'swap' });
const poppins = Poppins({ subsets: ['latin'], weight: ['400', '500'], variable: '--font-poppins', display: 'swap' });

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={`${teko.variable} ${poppins.variable}`}>
      <body>{children}</body>
    </html>
  );
}
