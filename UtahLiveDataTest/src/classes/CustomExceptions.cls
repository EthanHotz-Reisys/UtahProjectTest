/**
* @author Pankaj
* @description - Exceptions class to be throw Exception.              
*/


public with sharing class CustomExceptions {
    
    public class InputDataException extends Exception {}
    public class RequiredException extends Exception {}     
    public class GovernorLimitException extends Exception {}    
    public class CommunityException extends Exception{}
    public class RecordLockedException extends Exception{}
    public class AuthorizationException extends Exception {}
    
}