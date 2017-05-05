'use strict'
#####################################
# Alan Smith
# CIT FYP 2017
# This is the main config file
# for the angular app
# We define dependencies, routes
# and other settings here
#####################################
angular
    #Define module and dependencies
    .module 'corasEAMDemoApp', [
        'ngRoute',
        'ui.bootstrap',
        'ngMaterial'
    ]
    #Define config
    .config ($routeProvider, $httpProvider, $mdDateLocaleProvider) ->
        #Setup all our routes (pages)
        $routeProvider
            .when '/home',
                title: 'Home'
                templateUrl: 'views/home.html'
            .when '/source',
                title: 'Source Code'
                templateUrl: 'views/source-code.html'
            .when '/demos',
                title: 'Demo Videos'
                templateUrl: 'views/demo-videos.html'
                controller: 'VideoCtrl'
            .otherwise
                redirectTo: '/home'





angular
    #Define module and dependencies
    .module 'corasEAMDemoApp'
    .run ['$rootScope' , ($rootScope) ->
        $rootScope.$on('$routeChangeSuccess', (event, current, previous) ->
            $rootScope.title = current.$$route.title;
        )
    ]
