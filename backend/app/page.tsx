import Link from 'next/link';
import { Camera, FileText, Languages, History, Sparkles } from 'lucide-react';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      {/* Navigation */}
      <nav className="container mx-auto px-6 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Camera className="h-8 w-8 text-primary-600" />
            <span className="text-2xl font-bold text-gray-900">LifeLens AI</span>
          </div>
          <div className="flex items-center space-x-4">
            <Link href="/dashboard" className="text-gray-600 hover:text-gray-900 transition">
              Dashboard
            </Link>
            <Link
              href="/scanner"
              className="bg-primary-600 text-white px-6 py-2 rounded-lg hover:bg-primary-700 transition"
            >
              Start Scanning
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="container mx-auto px-6 py-20 text-center">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-5xl md:text-6xl font-bold text-gray-900 mb-6">
            Scan, Understand & Organize Your Documents with AI
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            Transform handwritten and printed documents into actionable insights. 
            LifeLens AI uses advanced OCR and machine learning to extract, organize, 
            and help you manage your important information.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/scanner"
              className="bg-primary-600 text-white px-8 py-4 rounded-lg text-lg font-semibold hover:bg-primary-700 transition flex items-center justify-center gap-2"
            >
              <Camera className="h-5 w-5" />
              Start Scanning
            </Link>
            <Link
              href="/dashboard"
              className="border-2 border-primary-600 text-primary-600 px-8 py-4 rounded-lg text-lg font-semibold hover:bg-primary-50 transition"
            >
              View Dashboard
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="container mx-auto px-6 py-20">
        <h2 className="text-3xl font-bold text-center text-gray-900 mb-12">
          Powerful Features
        </h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          <FeatureCard
            icon={<Languages className="h-8 w-8" />}
            title="Multilingual OCR"
            description="Support for English, Hindi, Urdu, Arabic, and more languages with accurate text recognition."
          />
          <FeatureCard
            icon={<FileText className="h-8 w-8" />}
            title="Handwriting Recognition"
            description="Advanced AI to read and understand handwritten notes and documents."
          />
          <FeatureCard
            icon={<Sparkles className="h-8 w-8" />}
            title="AI Analysis"
            description="Extract key information, summarize content, and identify actionable tasks."
          />
          <FeatureCard
            icon={<History className="h-8 w-8" />}
            title="Scan History"
            description="Save and organize all your scans with powerful search and filtering."
          />
        </div>
      </section>

      {/* CTA Section */}
      <section className="container mx-auto px-6 py-20">
        <div className="bg-primary-600 rounded-2xl p-12 text-center text-white">
          <h2 className="text-3xl font-bold mb-4">Ready to Get Started?</h2>
          <p className="text-xl mb-8 opacity-90">
            Start scanning your documents today and let AI help you stay organized.
          </p>
          <Link
            href="/scanner"
            className="bg-white text-primary-600 px-8 py-4 rounded-lg text-lg font-semibold hover:bg-gray-100 transition inline-block"
          >
            Start Free Trial
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="container mx-auto px-6 py-8 text-center text-gray-600">
        <p>&copy; 2024 LifeLens AI. All rights reserved.</p>
      </footer>
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode; title: string; description: string }) {
  return (
    <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-xl transition">
      <div className="text-primary-600 mb-4">{icon}</div>
      <h3 className="text-xl font-semibold text-gray-900 mb-2">{title}</h3>
      <p className="text-gray-600">{description}</p>
    </div>
  );
}
