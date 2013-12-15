/**
 * @author Andrzej Chodor
 */
public class Template {
    private final Pattern MERGE_FIELD_PATTERN = Pattern.compile('\\{!([\\w\\.]+)\\}');

    public final String content;

    private Object[] lexems;

    public Template(String content) {
        this.content = content;
    }

    public static Template fromEmailTemplate(String developerName) {
        EmailTemplate[] emailTpls = [
            SELECT Body, HtmlValue, TemplateType
            FROM EmailTemplate
            WHERE developerName = :developerName
        ];
        if(emailTpls.isEmpty()) {
            throw new TemplateNotFoundException('Template with Unique Name "' + developerName + '" was not found.');
        }
        if(emailTpls[0].TemplateType == 'html' || emailTpls[0].TemplateType == 'custom') {
            return new Template(emailTpls[0].HtmlValue);
        }
        return new Template(emailTpls[0].Body);
    }

    public String evaluate(MergeValues values) {
        compile();

        String buffer = '';
        for(Object lexem : lexems) {
            Object value = evaluate(lexem, values);
            buffer += format(value);
        }
        return buffer;
    }

    public String evaluate(SObject sobjectValue) {
        MergeValues values = new MergeValues();
        values.put(sobjectValue);
        return evaluate(values);
    }

    public String evaluate(Map<String, Object> values) {
        return evaluate(new MergeValues(values));
    }

    public void registerFieldsSecurely(MergeValues values) {
        compile();

        for(Object lexem : lexems) {
            if(lexem instanceof Gap) {
                values.registerFieldSecurely(((Gap)lexem).key);
            }
        }
    }

    private Boolean isCompiled() {
        return lexems != null;
    }

    private void compile() {
        if(isCompiled()) {
            return;
        }
    
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

    private static Object evaluate(Object lexem, MergeValues values) {
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

    public class TemplateNotFoundException extends Exception {
    }
}