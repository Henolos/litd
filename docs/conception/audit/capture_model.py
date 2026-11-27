"""Abstract documentary model; not game implementation."""
def model(s, mutation="none"):
    allowed = s.get("eligible", False) and (not s.get("restricted") or s.get("ng") or mutation == "ng")
    transfer = bool(allowed and (s.get("victory") or mutation == "defeat") and (not s.get("full") or mutation != "full"))
    return dict(allowed=bool(allowed), transfer=transfer, progress=transfer and mutation != "delay",
                occupied=mutation != "rank", pa=2 if mutation == "pa" else 1,
                identities=2 if mutation == "duplicate" else 1, transport=mutation == "transport")
