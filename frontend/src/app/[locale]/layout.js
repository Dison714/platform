import { notFound } from 'next/navigation';
import { isEnabledLocale, enabledLocales } from '../../i18n/config.js';
import { getDictionary } from '../../i18n/getDictionary.js';
import Header from '../components/Header.jsx';
import Footer from '../components/Footer.jsx';

export function generateStaticParams() {
  return enabledLocales().map((locale) => ({ locale }));
}

export default async function LocaleLayout({ children, params }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();
  const dict = await getDictionary(locale);

  return (
    <div className="layout-root">
      <Header locale={locale} dict={dict} />
      <main style={{ flex: 1 }}>{children}</main>
      <Footer dict={dict} />
    </div>
  );
}
