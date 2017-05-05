'use strict'
#####################################
# Alan Smith
# CIT FYP 2017
# This controller for the main
# webapp page
#####################################
angular.module 'corasEAMPublicApp'
    #Initialise controller, import modules and dependencies
    .controller 'HomeCtrl', (
        $scope,
        $location,
        $http,
        $config)->

    # Referenece to the location the user
    # wants to view shelters in
    $scope.location =
        chosenLocation: null

    # Get all available locations
    $scope.getAvailableLocations = ->
        $http
            method: 'get'
            url: "#{$config.server}open/locations"
        .then (response) ->
            $scope.availableLocations = response.data
        .catch (err) ->
            console.log err
            setTimeout ->
                $scope.getAvailableLocations()
            , 2000

    # Redirect to the page to display sheletrs in that location
    $scope.viewSheltersInLocation = ->
        $location.path "/shelters/location/#{$scope.location.chosenLocation.id}"

    # Call when page loads
    $scope.getAvailableLocations()

