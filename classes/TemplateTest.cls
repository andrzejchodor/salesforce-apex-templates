@IsTest
public class TemplateTest {
    public static testmethod void testSimpleTemplate() {
        String tplContent = '-start-{!valueA}-inner-{!valueB}-end-';
        Template tpl = new Template(tplContent);

        ObjectBag values = new ObjectBag(new Map<String,Object> {
            'valueA' => 'A',
            'valueB' => 'B'
        });

        Test.startTest();
            String result = tpl.evaluate(values);
        Test.stopTest();
        
        System.assertEquals('-start-A-inner-B-end-', result);
    }

    public static testmethod void testSObjectTemplate() {
        ObjectBag values = new ObjectBag();
        values.put([SELECT LastName FROM User WHERE Id = :UserInfo.getUserId()]);
        
        Test.startTest();
            String result = new Template('{!User.FirstName} {!User.LastName}')
                .evaluate(values);
        Test.stopTest();
        
        System.assertEquals(' ' + UserInfo.getLastName(), result);
    }

    public static testmethod void testEmailTemplateFactoryMethod() {
        Boolean exceptionThrown = false;
        try {
            Template tpl = Template.fromEmailTemplate('non-existing-template');
        } catch(Exception e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Should throw an exception if template does not exist.');

        insert new EmailTemplate(
            Name = 'Test Template',
            DeveloperName = 'Test',
            TemplateType = 'text',
            Body = 'Test',
            FolderId = UserInfo.getUserId()
        );

        Template tpl = Template.fromEmailTemplate('Test');
        System.assertEquals('Test', tpl.evaluate(new ObjectBag()));
    }
}