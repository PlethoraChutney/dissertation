return {
    Span = function (elem)
        if quarto.doc.is_format('docx') then
            if elem.classes:includes('aside') then
                return ""
            else
                return elem
            end
        end
    end
}