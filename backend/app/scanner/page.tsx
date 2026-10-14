'use client';

import { useState, useRef } from 'react';
import Link from 'next/link';
import { Camera, Upload, X, ArrowLeft, Loader2, Copy, Check } from 'lucide-react';

export default function Scanner() {
  const [image, setImage] = useState<string | null>(null);
  const [processing, setProcessing] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      if (file.size > 10 * 1024 * 1024) {
        setError('File too large. Maximum size is 10MB.');
        return;
      }
      if (!file.type.startsWith('image/')) {
        setError('Please select an image file.');
        return;
      }
      const reader = new FileReader();
      reader.onloadend = () => {
        setImage(reader.result as string);
        setError(null);
        setResult(null);
      };
      reader.readAsDataURL(file);
    }
  };

  const removeImage = () => {
    setImage(null);
    setResult(null);
    setError(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const processImage = async () => {
    if (!image) return;

    setProcessing(true);
    setError(null);

    try {
      const response = await fetch('/api/analyze-document', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer demo-user', // TODO: Replace with actual auth
        },
        body: JSON.stringify({
          image_data_url: image,
        }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Processing failed');
      }

      const data = await response.json();
      setResult(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to process image');
    } finally {
      setProcessing(false);
    }
  };

  const copyText = (text: string) => {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Navigation */}
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <Link href="/" className="flex items-center space-x-2">
              <Camera className="h-8 w-8 text-primary-600" />
              <span className="text-2xl font-bold text-gray-900">LifeLens AI</span>
            </Link>
            <div className="flex items-center space-x-4">
              <Link href="/dashboard" className="text-gray-600 hover:text-gray-900 transition">
                Dashboard
              </Link>
              <span className="text-gray-600">Scanner</span>
            </div>
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-6 py-8">
        <Link
          href="/dashboard"
          className="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-6"
        >
          <ArrowLeft className="h-5 w-5" />
          Back to Dashboard
        </Link>

        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Document Scanner</h1>
          <p className="text-gray-600 mb-8">
            Upload an image to extract text using AI-powered OCR
          </p>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6">
              {error}
            </div>
          )}

          {!image ? (
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-12 text-center hover:border-primary-500 transition cursor-pointer">
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                onChange={handleFileSelect}
                className="hidden"
                id="file-upload"
              />
              <label htmlFor="file-upload" className="cursor-pointer">
                <Upload className="h-16 w-16 text-gray-400 mx-auto mb-4" />
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  Upload an image
                </h3>
                <p className="text-gray-600 mb-4">
                  Drag and drop or click to select a file
                </p>
                <p className="text-sm text-gray-500">
                  Supports: JPEG, PNG, WebP (Max 10MB)
                </p>
              </label>
            </div>
          ) : (
            <div className="space-y-6">
              {/* Image Preview */}
              <div className="relative bg-white rounded-lg shadow overflow-hidden">
                <button
                  onClick={removeImage}
                  className="absolute top-4 right-4 bg-white p-2 rounded-full shadow hover:bg-gray-100 transition"
                >
                  <X className="h-5 w-5 text-gray-600" />
                </button>
                <img
                  src={image}
                  alt="Preview"
                  className="w-full h-auto max-h-96 object-contain"
                />
              </div>

              {!result ? (
                <button
                  onClick={processImage}
                  disabled={processing}
                  className="w-full bg-primary-600 text-white py-4 rounded-lg font-semibold hover:bg-primary-700 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                >
                  {processing ? (
                    <>
                      <Loader2 className="h-5 w-5 animate-spin" />
                      Processing...
                    </>
                  ) : (
                    <>
                      <Camera className="h-5 w-5" />
                      Extract Text
                    </>
                  )}
                </button>
              ) : (
                <div className="space-y-6">
                  {/* Results */}
                  <div className="bg-white rounded-lg shadow p-6">
                    <div className="flex items-center justify-between mb-4">
                      <h2 className="text-xl font-semibold text-gray-900">Extracted Text</h2>
                      <button
                        onClick={() => copyText(result.analysis.extracted_text)}
                        className="flex items-center gap-2 text-primary-600 hover:text-primary-700 transition"
                      >
                        {copied ? (
                          <>
                            <Check className="h-4 w-4" />
                            Copied!
                          </>
                        ) : (
                          <>
                            <Copy className="h-4 w-4" />
                            Copy
                          </>
                        )}
                      </button>
                    </div>
                    <div className="mb-4">
                      <span className="text-sm text-primary-600 font-medium">
                        Language: {result.analysis.detected_language}
                      </span>
                    </div>
                    <textarea
                      value={result.analysis.extracted_text}
                      onChange={(e) => {
                        setResult({
                          ...result,
                          analysis: {
                            ...result.analysis,
                            extracted_text: e.target.value,
                          },
                        });
                      }}
                      className="w-full h-64 p-4 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent resize-none"
                    />
                  </div>

                  {result.analysis.summary && (
                    <div className="bg-white rounded-lg shadow p-6">
                      <h2 className="text-xl font-semibold text-gray-900 mb-4">Summary</h2>
                      <p className="text-gray-600">{result.analysis.summary}</p>
                    </div>
                  )}

                  {result.analysis.tasks && result.analysis.tasks.length > 0 && (
                    <div className="bg-white rounded-lg shadow p-6">
                      <h2 className="text-xl font-semibold text-gray-900 mb-4">Extracted Tasks</h2>
                      <div className="space-y-3">
                        {result.analysis.tasks.map((task: any, index: number) => (
                          <div key={index} className="border border-gray-200 rounded-lg p-4">
                            <h3 className="font-medium text-gray-900">{task.title}</h3>
                            {task.description && (
                              <p className="text-gray-600 text-sm mt-1">{task.description}</p>
                            )}
                            {task.due_date && (
                              <p className="text-sm text-gray-500 mt-2">
                                Due: {task.due_date}
                              </p>
                            )}
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  <button
                    onClick={() => {
                      setImage(null);
                      setResult(null);
                    }}
                    className="w-full bg-gray-600 text-white py-4 rounded-lg font-semibold hover:bg-gray-700 transition"
                  >
                    Scan Another Document
                  </button>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
