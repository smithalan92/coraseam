'use strict'
#####################################
# Alan Smith
# CIT FYP 2017
# This controller is used to display
# shelters in a location
#####################################
angular.module 'corasEAMPublicApp'
    #Initialise controller, import modules and dependencies
    .controller 'SheltersCtrl', (
        $scope,
        $location,
        $http,
        $config,
        $routeParams,
        $uibModal,
        NgMap)->

    $scope.loading = true

    ### User object for adding a new client ###
    $scope.newClient =
        firstName: ''
        lastName: ''
        email: null
        phone: null
        gender: null
        DOB: new Date('01-01-1900')

    # Available genders for select box
    $scope.genders = ["Male", "Female"]

    # Reservation details
    $scope.reservation =
        madeFrom: 'Public WebApp'
        estimatedArrivalTime: moment()

    # Load all shelters for the requested location
    $scope.getSheltersForLocation = ->
        $scope.loading = true
        $http
            method: 'get'
            url: "#{$config.server}open/shelters/location/#{$routeParams.locationID}"
        .then (response) ->
            # We want to get the address for each shelter
            # since we dont store that in the DB
            return Promise.each response.data, (shelter) ->
                return new Promise (resolve, reject) ->
                    # Ask google for the street address based on the GPS cords
                    geocoder = new google.maps.Geocoder()
                    latlng = new google.maps.LatLng(shelter.GPSLatitude, shelter.GPSLongitude)
                    geocoder.geocode {'latLng': latlng}, (results, status) ->
                        if status is google.maps.GeocoderStatus.OK
                            if results[1]
                                shelter.address = results[1].formatted_address
                        return resolve shelter
            .then (shelters) ->
                $scope.shelters = shelters
                $scope.loading = false
        .catch (err) ->
            console.log err
            setTimeout ->
                $scope.getSheltersForLocation()
            , 2000

    # View shelter location on a map
    $scope.viewShelterLocation = (shelter) ->
        $scope.shelter =
            name: shelter.name
            address: shelter.address

        # Setup map config
        $scope.map =
            location: "#{shelter.GPSLatitude},#{shelter.GPSLongitude}"
            zoom: 16

        $scope.locationModal = $uibModal.open(
            animation: true,
            size: 'lg',
            templateUrl: 'views/modal/shelter-location.html',
            scope: $scope
        )

        # Makes sure the map loads
        $scope.triggerMap()

        $scope.locationModal.result.catch ->
            $scope.closeShelterLocationModal()

    $scope.closeShelterLocationModal = ->
        $scope.locationModal.close()
        # Due to the close animation, we use a timeout here
        # to stop modal content disappearing before fully closed
        setTimeout ->
            $scope.map = null
            $scope.shelterName = ''
            $scope.locationModal = null
        ,100


    # We need this to avoid Google maps showing just Grey
    # This essentially refocuses the map
    $scope.triggerMap = ->
        setTimeout ->
            return NgMap.getMap()
            .then (map) ->
                center = map.getCenter()
                google.maps.event.trigger(map, "resize")
                map.setCenter(center)
        , 500

    # Check is a shelter almost booked out
    $scope.isNearCapacity = (capacity, availability) ->
        percent = Math.floor (availability / capacity) * 100
        percent = 100 - percent
        return percent > 75

    # Show the modal to make a new reservation
    $scope.openReservationModal = (shelter) ->
        $scope.shelter = shelter

        $scope.reservationModal = $uibModal.open(
            animation: true,
            size: 'md',
            templateUrl: 'views/modal/add-reservation.html',
            scope: $scope
        )

        $scope.reservationModal.result.catch ->
            $scope.closeReservationModal()

    $scope.closeReservationModal = ->
        $scope.reservationModal.close()
        # Due to the close animation, we use a timeout here
        # to stop modal content disappearing before fully closed
        setTimeout ->
            $scope.shelter = null
            resetNewReservation()
            $scope.reservationModal = null
        ,100

    # Add a reservation via the API
    $scope.addReservation = ->
        $scope.error = null
        $scope.addReservationSuccess = false
        $scope.addWorking = true

        # Check the user gave a DOB, We're assuming noone that was born
        # on the 1st Jan 1900 is using the service.
        if moment($scope.newClient.DOB).format("YYYY-MM-DD") is '1900-01-01'
            $scope.error = "You need add a DOB for the client"
            $scope.addWorking = false
            return

        # Make sure they pick a gender
        if not $scope.newClient.gender
            $scope.error = "You need select the clients gender"
            $scope.addWorking = false
            return

        # Set request data
        data =
            client:
                firstName: $scope.newClient.firstName
                lastName: $scope.newClient.lastName
                DOB: moment($scope.newClient.DOB).format("YYYY-MM-DD")
                gender: $scope.newClient.gender
            reservation:
                shelterID: $scope.shelter.id
                madeFrom: $scope.reservation.madeFrom
                estimatedArrivalTime: moment($scope.reservation.estimatedArrivalTime).format("HH:mm")

        # If we have a email and phone add it
        data.client.email = $scope.newClient.email if $scope.newClient.email
        data.client.phone = $scope.newClient.phone if $scope.newClient.phone

        # Make the request
        $http
            method: 'post'
            url: "#{$config.server}open/reservations/add"
            data:data
        .then (res) ->
            $scope.newResNumber = res.data.reservationNumber
            $scope.addReservationSuccess = true
            $scope.addWorking = false
            resetNewReservation()
        .catch (err) ->
            $scope.addWorking = false
            $scope.error = if err?.data?.error then err.data.error else "Something went wrong with the server request"

    ### Private Functions ###

    # Reser the details
    resetNewReservation = ->
        $scope.newClient =
            firstName: ''
            lastName: ''
            email: null
            phone: null
            gender: null
            DOB: new Date('01-01-1900')

        $scope.reservation =
            madeFrom: 'Public WebApp'
            estimatedArrivalTime: moment()

    $scope.getSheltersForLocation()

