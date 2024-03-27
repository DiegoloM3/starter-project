# Coding Guidelines
Symmetry follows a very strict set of coding guidelines to ensure that the maintanability of the code is high level.
This guidelines are largely inspired by the following resources:
- [Clean Code Notes](https://github.com/JuanCrg90/Clean-Code-Notes)
- [Clean Code Book](./clean-code-book.pdf)

## Who enforces these guidelines?
This guidelines are enforced by the code reviewers (basically senior developers) on a per-pull request basis 
*This of course does not apply to this project, you must review your own Pull Requests.*
## What are the consequences of violating these guidelines?
Any violation of these guidelines can result in requests for changes in your pull requests, rejected pull requests and in the worst-case scenario; closed pull requests.

## The Guidelines
*Reviewers can refer to these as **CG{n}** in pull request comments, where {n} is the number of the rule*
1. Always apply the Boy Scout rule  
The Boy Scout Rule says **"always leave the campground cleaner than you found it"**. We must follow this rule in our code.  
If we update functionality which was not tested, we create the tests ourselves.  
If we find a way to refactor old code when creating new features, we refactor this code.  
This is a requirement of our jobs as software engineers in Symmetry. It is not an individual task or something you do every 'x' amount of time, it is something you do in each and every change to the codebase.  
2. Use Meaningful names  
    - 2.1 Follow Set Conventions
    Follow the already set convention for naming in "typical" files (eg: use_cases, repositoryImpls, Entities, ...). This "typical" files MUST follow the same conventions and the classes inside them as well.
    - 2.1 Use Intention-Revealing Names  
    Use names that reveal the intention of variables, classes, or functions.  
    - 2.2 Avoid Disinformation  
    ALWAYS **avoid leaving false clues that obscure the meaning of code**.   
    You should avoid words whose entrenched meanings vary from our intended meaning.  
    - 2.3 Use Pronauncable Names  
    Use names which you can say out loud so that you can talk about them with your peers ie: make it easy to refer to variables/functions/classes in natural language  
    - 2.4 Class Names are nouns  
    - 2.5 Function names are verbs  

3. Keep functions as simple as possible and as small as possible  
    - 3.1 Make functions SMALL  
    - 3.2 Ensure that the nested structure of functions is not greater than 2 (if it is, refactor)  
    - 3.3 Follow The Single Responsibility Principle (SRP)
    Functions should do exclusively one thing and one thing only. If they do more than that, refactor.  
    - 3.4 Use Descriptive Names  
    Don't be afraid to **make a name long**. A long descriptive name is better than a short
    enigmatic name or a long descriptive comment.  
    - 3.5 Keep Number of Arguments low  
    The ideal number of arguments for a function is zero (niladic). Next comes one
    (monadic), followed closely by two (dyadic). Three arguments (triadic) should be
    avoided always. More than three (polyadic) requires very special
    justification—and then shouldn’t be used anyway.  
    This is to ensure that the unit tests of a function are simple.   
    - 3.6 Command Query Separation  
**Functions should either do something or answer something, but not both**. Either your
function should change the state of an object, or it should return some information about that
object. Doing both often leads to confusion.  

4. **ALWAYS DO TEST DRIVEN DEVELOPMENT (TDD)**  
*This rule does not apply to this project (unless of course you want to MAXIMALLY OVERDELIVER)*
We ALWAYS follow the 3 laws of TDD at Symmetry:  
-  First Law: You may not write production code until you have written a failing
unit test.  
- Second Law: You may not write more of a unit tests than is sufficient to fail,
and not comipling is failing.  
- Third Law: You may not write more production code than is sufficient to pass
the currently failing tests.  
Our testing process is inspired by [this tutorial](https://www.youtube.com/watch?v=g2Mup12MccU)  
    - 4.1 Test All Functionality you write  
    - 4.2 Create/Adapt Integration tests when you add/change a User Journey in the app.  

5. Keep Classes Small  
    - 5.1 Make classes small  
    - 5.2 Ensure classes have one responsibiilty  
    - 5.3 Keep the number of instance variables low  
    Classes Should have a small number of instance variables. Each of the methods of a
    class should manipulate one or more of those variables.

6. Use Abstract Classes to Isolate from Change  
    - 6.1 Use abstract classes  
        Needs will change, therefore code will change. A client class depending upon concrete details is at
        risk when those details change. We can introduce intefaces and abstract classes to
        help isolate the impact of those details