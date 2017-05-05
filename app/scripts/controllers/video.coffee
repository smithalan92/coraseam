'use strict'
#####################################
# Alan Smith
# CIT FYP 2017
# This controller is used to switch
# out the video to play
#####################################
angular.module 'corasEAMDemoApp'
    #Initialise controller, import modules and dependencies
    .controller 'VideoCtrl', (
        $scope
        $sce)->

    videos =
        full: "https://www.youtube.com/embed/PGqr6qldt-I?rel=0"
        admin: "https://www.youtube.com/embed/l-_TMqgS7is?rel=0"
        public: "https://www.youtube.com/embed/oHqcoCwvXjs?rel=0"
        desktop: "https://www.youtube.com/embed/as99YN0tTwY?rel=0"
        shelter: "https://www.youtube.com/embed/D97t8YCfE3I?rel=0"
        android: "https://www.youtube.com/embed/XnXkEV1xmyM?rel=0"

    $scope.currentVideo = $sce.trustAsResourceUrl(videos.full)



    $scope.switchVideo = (video) ->
        $scope.currentVideo = $sce.trustAsResourceUrl(videos[video])

