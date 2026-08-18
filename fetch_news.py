import os
import feedparser
from supabase import create_client
from dateutil import parser
from datetime import datetime

# GitHub Secrets నుండి కీలను రీడ్ చేయడం
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# న్యూస్ ఫీడ్స్ జాబితా (తెలుగు & ఇంగ్లీష్)
FEEDS = [
    {
        "url": "https://news.google.com/rss/headlines/section/topic/ENTERTAINMENT?hl=te&gl=IN&ceid=IN:te",
        "category": "movies",
        "language": "telugu"
    },
    {
        "url": "https://news.google.com/rss/headlines/section/topic/SPORTS?hl=te&gl=IN&ceid=IN:te",
        "category": "sports",
        "language": "telugu"
    },
    {
        "url": "https://news.google.com/rss/headlines/section/topic/POLITICS?hl=te&gl=IN&ceid=IN:te",
        "category": "politics",
        "language": "telugu"
    },
    {
        "url": "https://news.google.com/rss?hl=te&gl=IN&ceid=IN:te",
        "category": "regional",
        "language": "telugu"
    }
]

def fetch_and_save():
    for item in FEEDS:
        print(f"Fetching: {item['category']} ({item['language']})")
        feed = feedparser.parse(item["url"])
        
        for entry in feed.entries:
            try:
                # ప్రచురణ సమయాన్ని సరిగ్గా ఫార్మాట్ చేయడం
                pub_date = parser.parse(entry.published).isoformat() if hasattr(entry, 'published') else datetime.utcnow().isoformat()
                
                article = {
                    "title": entry.title,
                    "summary": entry.get("summary", ""),
                    "source_url": entry.link,
                    "source_name": entry.get("source", {}).get("title", "Google News"),
                    "category": item["category"],
                    "language": item["language"],
                    "published_at": pub_date
                }
                
                # డేటాబేస్‌లో సేవ్ చేయడం (డూప్లికేట్ ఉంటే అప్‌డేట్ అవుతుంది)
                supabase.table("news_articles").upsert(article, on_conflict="source_url").execute()
            except Exception as e:
                print(f"Error parsing article: {e}")

if __name__ == "__main__":
    fetch_and_save()
    print("News update completed!")
