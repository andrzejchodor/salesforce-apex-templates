@IsTest
class MergeValuesTest {
    static testmethod void testBasicUse() {
        Map<String, Object> values = new Map<String, Object> {
            'someString' => 'someValue',
            'someMap' => new Map<String, Object> {
                'someChild' => 'someChildValue',
                'someNumber' => 1,
                'someCase' => new Case(subject = 'Test Case')
            }
        };

        MergeValues bag = new MergeValues(values);

        System.assertEquals('someValue', bag.get('someString'));
        System.assertEquals('someChildValue', bag.get('someMap.someChild'));
        System.assertEquals(1, bag.get('someMap.someNumber'));
        System.assertEquals('Test Case', bag.get('someMap.someCase.subject'));
    }

    static testmethod void testUnretrievedField() {
        // LastName is not retrieved.
        User someUser = [
            SELECT Id, FirstName FROM User WHERE Id = :UserInfo.getUserId()
        ];

        MergeValues bag = new MergeValues();
        bag.put(someUser);

        System.assertEquals(UserInfo.getFirstName(), bag.get('User.FirstName'));
        
        Boolean exceptionThrown = false;
        try {
            bag.get('User.LastName');
        } catch(SObjectException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Field User.LastName was not retrieved, thus an exception was expected.');
    }

    static testmethod void testQueryingSObjects() {
        MergeValues bag = new MergeValues();
        bag.registerFieldSecurely('User.FirstName');
        bag.registerFieldSecurely('User.LastName');
        bag.putSObject('User', UserInfo.getUserId());

        System.assertEquals(UserInfo.getFirstName(), bag.get('User.FirstName'));
        System.assertEquals(UserInfo.getLastName(), bag.get('User.LastName'));
    }
}