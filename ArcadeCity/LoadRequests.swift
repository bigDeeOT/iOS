//
//  LoadRequests.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/14/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class LoadRequests {
    private static var requestList = [RideRequest]()
    static var needToLoad = true
    init() {
        if LoadRequests.needToLoad {
       loadRequests()
            LoadRequests.needToLoad = false
        }
    }
    
    func get() -> [RideRequest] {
        return LoadRequests.requestList
    }
    
    func add(request: RideRequest) {
        LoadRequests.requestList.append(request)
    }
    
    private func loadRequests() {
        var rider = User(url: URL(string: "http://i.imgur.com/CO5oZG1.jpg")!, name: "Booker T Washington")
        rider.phone = "512 686-7920"
        var request = RideRequest(rider: rider)
        request.text = "Pickup domain to riveride"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/ezZRRss.jpg")!, name: "Donald J Trump")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Airport to Capitol please"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/1jP1Zwv.jpg")!, name: "Wolverine")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Hey guys I have a favor to ask. I don't know if this is the right place but is it possible for someone to pick up my dog from my apartment and bring him to the vet? I'm so worried about him please help!"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/9QBGS2m.jpg")!, name: "Gregory Fenves")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Redbud to UT"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/nnCNDRO.jpg")!, name: "Doggy")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Hyde Park to Zilker"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
    }
}
