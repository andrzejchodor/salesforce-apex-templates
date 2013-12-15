@IsTest
public class TemplateTest {
    static testmethod void testSimpleTemplate() {
        String tplContent = '-start-{!valueA}-inner-{!valueB}-end-';
        Template tpl = new Template(tplContent);

        Test.startTest();
            String result = tpl.evaluate(new Map<String,Object> {
                'valueA' => 'A',
                'valueB' => 'B'
            });
        Test.stopTest();
        
        System.assertEquals('-start-A-inner-B-end-', result);
    }

    static testmethod void testSObjectTemplate() {
        User anUser = [SELECT LastName FROM User WHERE Id = :UserInfo.getUserId()];
        
        Test.startTest();
            String result = new Template('{!User.FirstName} {!User.LastName}')
                .evaluate(anUser);
        Test.stopTest();
        
        System.assertEquals(' ' + UserInfo.getLastName(), result);
    }

    static testmethod void testEmailTemplateFactoryMethod() {
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
        System.assertEquals('Test', tpl.evaluate(new MergeValues()));
    }

    static testmethod void testRegisteringFields() {
        MergeValues bag = new MergeValues();

        Template tpl = new Template('{!User.FirstName} {!User.LastName}');
        tpl.registerFieldsSecurely(bag);

        bag.putSObject('User', UserInfo.getUserId());
        String result = tpl.evaluate(bag);

        System.assertEquals(UserInfo.getFirstName() + ' ' + UserInfo.getLastName(), result);
    }
}