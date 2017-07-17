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
        var rider = User(url: URL(string: "http://www.history.com/s3static/video-thumbnails/AETN-History_Prod/74/192/History_Speeches_2001_Booker_T_Washington_Race_Relations_still_624x352.jpg")!, name: "Booker T Washington")
        rider.phone = "512 686-7920"
        var request = RideRequest(rider: rider)
        request.text = "Pickup domain to riveride"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://www.slate.com/content/dam/slate/articles/news_and_politics/politics/2016/04/160422_POL_Donald-Trump-Act.jpg.CROP.promo-xlarge2.jpg")!, name: "Donald J Trump")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Airport to Capitol please"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://digitalspyuk.cdnds.net/17/10/980x490/landscape-1489149452-wolverine-surprise-hugh-jackman-wants-to-be-wolverine-forever-and-here-s-how-he-can-do-it.jpeg")!, name: "Wolverine")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Hey guys I have a favor to ask. I don't know if this is the right place but is it possible for someone to pick up my dog from my apartment and bring him to the vet? I'll pay for everything but he just really needs to go to the vet right now."
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://media.cmgdigital.com/shared/img/photos/2015/04/20/28/cd/rbz_UT_Greg_Fenves_03.JPG")!, name: "Gregory Fenves")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Redbud to UT"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "https://vetstreet.brightspotcdn.com/dims4/default/79f1bd2/2147483647/crop/0x0%2B0%2B0/resize/645x380/quality/90/?url=https%3A%2F%2Fvetstreet-brightspot.s3.amazonaws.com%2F83%2F9e8de0a7f411e0a0d50050568d634f%2Ffile%2FPembroke-Welsh-Corgi-3-645mk62711.jpg")!, name: "Doggy")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Hyde Park to Zilker"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
    }
}
