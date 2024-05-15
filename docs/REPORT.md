# Symmetry Report

## 1. Introduction

This project was a real challenge! To be honest, at first I felt that it would meet all the requested requirements. Since I had no experience in mobile development and no experience with Firebase, my first 36 ~ 48 hours (of course, living and doing personal and academic stuff) were dedicated to learning and experimenting with these technologies.

I felt confident since I recently met the real need of using architectures and design patterns in software development. I’ll talk about the next points which were the hardest challenges I faced.

## 2. Learning Journey

I was really excited at the beginning, mobile development was a field which I have wanted to delve into for a while. I'm an Ubuntu/Linux user, so I also learned interesting things about SDKs installation (since flutter installation is subtly different from other programming languages on this OS). For this I used the official documentation at Flutter Dev.

Then, I proceeded to learn the basics of Flutter, my first application (guided with codelab) and its syntax similarities with JavaScript (no restrictive file structure) or even C# (such as Future with Task).

Then I dedicated a certain amount of time understanding Firebase and the problems this tool solves. It’s an insane-sized tool, the pinned resources on the different READMEs were helpful. However I couldn't get deep into a robust implementation of this tool with Flutter. Here comes my biggest problem.

## 3. Challenges Faced

After about 48 hours, I tried to run the delivered app on my local device. Unfortunately, I couldn't. There was low level stuff (related to android folder) that gave me a lot of problems and researches that came to nothing… Before proceeding, why did I wait 48 hours in order to run the base project? Well, something I learned (and my biggest mistake here) is that code is, most of the time, the last thing a programmer does. The biggest concern is really understanding the product. Since I dedicated a certain amount of time to learning about technologies of my unknowledge such as Flutter and Firebase, and a certain amount of time to practice them, I postponed testing to see if at least the base project works. (As proof of my work, here are some diagrams that I made before testing the base project) (I changed the position of the diagrams to the Overdelivery section).

So, I decided and proceeded with re-implementing the base application following the Flutter Clean Architecture tutorial video. I achieved this successfully. However, here comes my second big problem. And I didn’t take into account the use of many third party packages. Although third party packages are made focusing on simplicity and reducing boilerplate, My no-knowledge context did not allow me to get the most out of them. Mostly reflected on my own implementation

## 4. Reflection and Future Directions

I learned a lot, my first technical test. First thing I’ll do on my next projects is review the code, also reviewing the code is a great way to understand requirements (in fact, if I hadn't taken the initiative to review the code, maybe I would have spent more time learning Flutter and Firebase).

Also, why not, look for a set of clear instructions. This since I also have doubts related to the GitHub repository, such as: “Should I fork this project or add my branches here?”.

A great idea I have about this project was to implement Firebase Authentication, and with this role-based user management, where common users can enjoy reading journalists articles, and journalists can, in addition to reading articles from their colleagues, write new articles. All in the same app.

## 5. Proof of the project

I would have loved to meet all the requested requirements. Since I worked on reimplementing the base project, I will also add some of its features.

<video controls src="https://res.cloudinary.com/dt2xucpq2/video/upload/v1715777065/_temp/fwfuxawyl7iuwivcgmm7.mp4" title="Demo News App"></video>

<video controls src="https://res.cloudinary.com/dt2xucpq2/video/upload/v1715777064/_temp/zbimwjqhvphvdyenfx5f.mp4" title="Firebase reflected changes"></video>

## 6. Overdelivery

My diagrams fit perfectly here.

![Use Case News App](https://res.cloudinary.com/dt2xucpq2/image/upload/v1715777517/_temp/lsulbnpclk36snigyf07.png)

![Use Case News App MVP](https://res.cloudinary.com/dt2xucpq2/image/upload/v1715777516/_temp/h0qllzn4ldwoxnfajlhf.png)

![Architecture high level](https://res.cloudinary.com/dt2xucpq2/image/upload/v1715777516/_temp/xam3ee9hxvimnhqbkcfl.png)

As mentioned above, a feature I would love to implement (in order to reflect overdelivery value) was the authentication and the role-based management of the users that use the app.

More practice with libraries such as bloc or dio would have been very helpful, like prototypes of apps implementing these ones.

Also, I think a very good practice is to follow a correct branching model, making Pull Requests when a feature is ready to deliver:

![Branching Model](https://res.cloudinary.com/dt2xucpq2/image/upload/v1715778185/_temp/l9nlnwtlr3wlcgrt11yj.png)

And why not, I'll show some code snippets of my code:

- Minor:

  ```dart
  // I wrapped TextFormFields of my Form into its own Widget class to avoid boilerplate. Such as React components.

  class ArticleFormTextField extends StatelessWidget {
      final String labelText;
      final String validationMessage;
      final TextInputType? keyboardType;
      final bool? autofoucs;
      final TextEditingController controller;
  //...
      @override
      Widget build(BuildContext context) {
      return TextFormField(
          controller: controller,
          autofocus: autofoucs ?? false,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
          if (value == null || value.isEmpty) {
              return validationMessage;
          }
          return null;
          },
          decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          ),
          keyboardType: keyboardType ?? TextInputType.text,
      );
      }
  }
  ```

- Good:

  ```dart
  // I successfully achieved follow the architecture to insert the article into Firestore

  // On submit form
      if (addArticleFormKey.currentState!.validate()) {
          var article = ArticleEntity(
              // ...
          );
          BlocProvider.of<RemoteArticlesBloc>(context)
              .add(AddArticle(article));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Article uploaded successfully!')),
          );
      }
  // ...
  ```

  ```dart
  // Registering instances with get it
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  sl.registerSingleton<FirestoreDatabaseService>(FirestoreDatabaseService());

  sl.registerSingleton<GetArticlesFromFirestoreUseCase>(GetArticlesFromFirestoreUseCase(sl()));
  sl.registerSingleton<AddArticleToFirestoreUseCase>(AddArticleToFirestoreUseCase(sl()));
  // ...
  ```

  ```dart
  // Regisering use case
  class AddArticleToFirestoreUseCase implements UseCase<void, ArticleEntity> {
      final ArticleRepository _articleRepository;

      AddArticleToFirestoreUseCase(this._articleRepository);

      @override
      Future<void> call({ArticleEntity? params}) {
          return _articleRepository.addArticleToFirestore(params!);
      }
  }
  // And so on...
  ```
