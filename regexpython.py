import re
text = "Spider.Man.Far.From.Home.2019.1080p.WEB-DL.DD5.1.H264-FGT.mkv"

result = re.search(r"[a-zA-Z]+", text)

print(result.group(0))
