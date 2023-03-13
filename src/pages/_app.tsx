import type { AppProps } from 'next/app';
import '../styles/tailwind.css';
import React from 'react';

function MyApp({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}

export default MyApp;
