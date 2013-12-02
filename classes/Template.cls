public class Template {
    private final Pattern MERGE_FIELD_PATTERN = Pattern.compile('\\{!([\\w\\.]+)\\}');

    public final String content;

    public List<Object> lexems;

    public Template(String content) {
        this.content = content;
    }

    public static Template fromEmailTemplate(String developerName) {
        EmailTemplate emailTpl = [
            SELECT Body, HtmlValue, TemplateType
            FROM EmailTemplate
            WHERE developerName = :developerName
        ];
        if(emailTpl.TemplateType == 'HTML') {
            return new Template(emailTpl.HtmlValue);
        }
        return new Template(emailTpl.Body);
    }

    public String evaluate(ObjectBag values) {
        if(!isCompiled()) {
            compile();
        }

        String buffer = '';
        for(Object lexem : lexems) {
            Object value = evaluate(lexem, values);
            buffer += format(value);
        }
        return buffer;
    }

    private Boolean isCompiled() {
        return lexems != null;
    }

    private void compile() {
        lexems = new List<Object>();

        Matcher contentMatcher = MERGE_FIELD_PATTERN.matcher(content);
        Integer processedEnd = 0;
        while(contentMatcher.find()) {
            if(processedEnd < contentMatcher.start()) {
                lexems.add(content.substring(processedEnd, contentMatcher.start()));
            }

            Gap gapLexem = new Gap(contentMatcher.group(1));
            lexems.add(gapLexem);

            processedEnd = contentMatcher.end();
        }

        if(processedEnd < content.length()) {
            lexems.add(content.substring(processedEnd));
        }
    }

    private static Object evaluate(Object lexem, ObjectBag values) {
        if(lexem instanceof String) {
            return lexem;
        }

        if(lexem instanceof Gap) {
            String key = ((Gap)lexem).key;
            try {
                return values.get(key);
            } catch(SObjectException e) {
                return null;
            }
        }
        
        return null;
    }

    private static String format(Object value) {
        if(value == null) {
            return '';
        } else if(value instanceof String) {
            return (String)value;
        }

        return String.valueOf(value);
    }

    private class Gap {
        public final String key;

        Gap(String key) {
            this.key = key;
        }
    }
}