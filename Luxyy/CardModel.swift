//
//  CardModel.swift
//  WatchProject
//
//  Created by Stanley Chiang on 12/12/15.
//  Copyright © 2015 Stanley Chiang. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class CardModel: NSObject {

    func makePromiseRequest(method: Alamofire.Method, url: NSURL) -> Promise<String> {
        return Promise { fulfill, reject in
            Alamofire.request(method, url).responseString { response in
                if response.result.isSuccess {
                    fulfill(response.result.value!)
                }else{
                    reject(response.result.error!)
                }
            }
        }
    }
    
    func getContent(link:String, success:(response:String)->Void,failure:(error:AnyObject)->Void){
        Alamofire.request(.GET, link) .responseString { response in
            if response.result.isSuccess {
                success(response: response.result.value!)
            }else{
                failure(error: response.result.error!)
            }
        }
    }
}
