# sails-angular-resource
Angular model CRUD allows you to use Sails.js's socket.io api



### How to use

Inject dependancy
```
angular.module('app', ['sailsService'])

```

Create a CRUD service with a same name like your model in your api/model

```
angular.module("app")
.factory('Post', ['Post', [ 'SailsResource', function (SailsResource) {
  return new SailsResource('post');
}]);
```

After in your angular controller or directives, inject your Factory like below
```
angular.module("app")
.controller('testCtrl', ['$scope', 'Post', function ($scope, Post) {

  Post.query({}, function() {
    $scope.posts = Post.resources
  });

  Post.get(id, function() {
    $scope.post = Post.resource
  });

}
...

```

Other actions

```
Post.create({title: 'my title', content: 'my content'}, function(res) {
  console.log(res);
});

Post.update({title: 'my title', content: 'my content'}, id, function(res) {
  console.log(res);
});

Post.delete(id, function(res) {
  console.log(res);
});



```




