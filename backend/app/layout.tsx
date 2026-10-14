import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'LifeLens AI - Document Scanning & OCR',
  description: 'Transform handwritten and printed documents into actionable insights with AI-powered OCR and document analysis.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
