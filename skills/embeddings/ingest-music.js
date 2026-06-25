import { embed, save_store } from './engine.js'

const LASTFM_API = 'http://ws.audioscrobbler.com/2.0/'

async function fetch_top_artists(api_key, user, period = '12month', limit = 50) {
  const url = `${LASTFM_API}?method=user.gettopartists&user=${user}&api_key=${api_key}&format=json&period=${period}&limit=${limit}`
  const res = await fetch(url)
  const data = await res.json()
  return data.topartists.artist
}

async function fetch_artist_tags(api_key, artist_name) {
  const url = `${LASTFM_API}?method=artist.gettoptags&artist=${encodeURIComponent(artist_name)}&api_key=${api_key}&format=json`
  const res = await fetch(url)
  const data = await res.json()
  if (!data.toptags?.tag) return []
  return data.toptags.tag.slice(0, 5).map(t => t.name)
}

async function main() {
  const api_key = process.env.LASTFM_API_KEY
  const user = process.env.LASTFM_USER

  if (!api_key || !user) {
    console.log('Set LASTFM_API_KEY and LASTFM_USER in ~/.anotht-agent/.env')
    process.exit(1)
  }

  const artists = await fetch_top_artists(api_key, user)
  const items = []

  for (const artist of artists) {
    const tags = await fetch_artist_tags(api_key, artist.name)
    const text = `${artist.name} — ${tags.join(', ')} (${artist.playcount} plays)`
    const vec = await embed(text)
    items.push({
      id: `music::artist::${artist.name}`,
      text,
      source: 'music',
      vec
    })
    console.log(`embedded: ${artist.name} [${tags.join(', ')}]`)
  }

  save_store('music', items)
  console.log(`Stored ${items.length} artist embeddings`)
}

main()
