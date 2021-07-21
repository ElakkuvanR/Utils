# Find src from <img> tag - Regex

        string htmlText = "<img src='https://asas/asd/aasadasd.png?ffdf=123' />";
        Regex regImg = new Regex(@"<img\b[^<>]*?\bsrc[\s\t\r\n]*=[\s\t\r\n]*[""']?[\s\t\r\n]*(?<imgUrl>[^\s\t\r\n""'<>]*)[^<>]*?/?[\s\t\r\n]*>", RegexOptions.IgnoreCase);
        MatchCollection matches = regImg.Matches(htmlText);
        int i = 0;
        string[] sUrlList = new string[matches.Count];

        foreach (Match match in matches)
        {
            sUrlList[i++] = match.Groups["imgUrl"].Value;
        }
