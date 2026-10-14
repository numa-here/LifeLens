export default function Home() {
  return (
    <div style={{ padding: '2rem' }}>
      <h1>LifeLens API</h1>
      <p>Backend API for LifeLens application</p>
      <ul>
        <li><a href="/api/analyze-document">POST /api/analyze-document</a></li>
        <li><a href="/api/daily-briefing">POST /api/daily-briefing</a></li>
        <li><a href="/api/upload">POST /api/upload</a></li>
        <li><a href="/api/tasks">GET/POST /api/tasks</a></li>
        <li><a href="/api/scans">GET /api/scans</a></li>
      </ul>
    </div>
  )
}
