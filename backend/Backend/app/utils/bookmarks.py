import datetime
from typing import List, Dict, Any, Optional
from bs4 import BeautifulSoup, Tag
from loguru import logger


def parse_netscape_html(html_content: str) -> List[Dict[str, Any]]:
    """
    Parses a standard Netscape HTML bookmarks file.
    Returns a flat list of bookmarks with hierarchical folder pathways:
    [{"title": "Google", "url": "https://google.com", "folders": ["Search", "Main"]}]
    """
    soup = BeautifulSoup(html_content, "html.parser")
    parsed_bookmarks = []

    def traverse(dl_tag: Tag, current_path: List[str]) -> None:
        # A DL tag contains DT nodes. Each DT node can represent a bookmark (A tag) or folder (H3 + DL tag)
        for child in dl_tag.find_all("dt", recursive=False):
            # Check if this child represents a folder
            h3 = child.find("h3", recursive=False)
            if h3:
                folder_name = h3.get_text(strip=True)
                nested_dl = child.find("dl", recursive=False)
                if nested_dl:
                    traverse(nested_dl, current_path + [folder_name])
                continue

            # Check if this child represents a link bookmark
            a = child.find("a", recursive=False)
            if a:
                url = a.get("href")
                title = a.get_text(strip=True)
                if url:
                    parsed_bookmarks.append({
                        "title": title or url,
                        "url": url,
                        "folders": current_path
                    })

    # Begin traversal from base level DL tags
    base_dls = soup.find_all("dl")
    if base_dls:
        # Usually the first <DL> holds all items
        traverse(base_dls[0], [])
    else:
        # Fallback: parse all A tags directly if the structure is flat or malformed
        logger.warning("No DL tags detected. Falling back to extracting all anchors directly.")
        for a in soup.find_all("a"):
            url = a.get("href")
            title = a.get_text(strip=True)
            if url:
                parsed_bookmarks.append({
                    "title": title or url,
                    "url": url,
                    "folders": []
                })

    return parsed_bookmarks


def generate_netscape_html(bookmarks_data: List[Dict[str, Any]]) -> str:
    """
    Generates standard Netscape HTML Bookmark format string from database results.
    `bookmarks_data` should contain dictionary structures containing `title`, `url`, and optionally `folder_name`.
    """
    lines = [
        "<!DOCTYPE NETSCAPE-Bookmark-file-1>",
        "<!-- This is an automatically generated file.",
        "     It will be read and overwritten. -->",
        '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">',
        "<TITLE>Bookmarks</TITLE>",
        "<H1>Bookmarks</H1>",
        "<DL><p>"
    ]

    # Map bookmarks into folder paths
    folders: Dict[str, List[Dict[str, str]]] = {"root": []}
    for bm in bookmarks_data:
        folder = bm.get("folder_name") or "root"
        if folder not in folders:
            folders[folder] = []
        folders[folder].append({
            "title": bm.get("title", ""),
            "url": bm.get("url", "")
        })

    # Render Root items
    for item in folders.get("root", []):
        lines.append(f'    <DT><A HREF="{item["url"]}">{item["title"]}</A>')

    # Render Folders
    for folder_name, items in folders.items():
        if folder_name == "root":
            continue
        lines.append(f'    <DT><H3>{folder_name}</H3>')
        lines.append("    <DL><p>")
        for item in items:
            lines.append(f'        <DT><A HREF="{item["url"]}">{item["title"]}</A>')
        lines.append("    </DL><p>")

    lines.append("</DL><p>")
    return "\n".join(lines)
