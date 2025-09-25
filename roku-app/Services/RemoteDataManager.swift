import Foundation
import Alamofire

protocol Cancelable {
    func cancelTask()
}

extension DataRequest: Cancelable {
    func cancelTask() {
        cancel()
    }
}

class RemoteDataManager {
    static let shared: RemoteDataManager = {
        let session: Session = Session(interceptor: nil, eventMonitors: [APILogger.shared])
        session.sessionConfiguration.timeoutIntervalForRequest = 30
        let remoteDataManager: RemoteDataManager = .init(session: session)
        return remoteDataManager
    }()
    
    let session: Session
    
    init(session: Session) {
        self.session = session
    }
    
    @discardableResult
    func login(loginRequestDTO: LoginRequestDTO, completion: @escaping (AppSession?)->Void ) -> Cancelable? {
        do {
            let sid = try JSONEncoder().encode(loginRequestDTO)
            let parameters = try JSONSerialization.jsonObject(with: sid, options: []) as? [String: Any]
            
            let headers: HTTPHeaders = [:]
            let request = session.request(URL(string: Constants.App.apiBaseURL+"app/login")!,
                                          method: .post,
                                          parameters: parameters,
                                          encoding: JSONEncoding.default,
                                          headers: headers)
          
            return request.validate().responseDecodable(of: LoginResponseDataDTO.self) { (response) in
                switch response.result {
                case .success(let value):
                    completion(value.toModel())
                case .failure(let error):
                    print("Login error: \(error)")
                    completion(nil)
                }
            }
        } catch {
            completion(nil)
        }
        return nil
    }
}

final class APILogger: EventMonitor {
    static let shared = APILogger()
    
    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        print("---> Request Created <---")
        print(request.description)
    }
    
    func requestDidFinish(_ request: Request) {
        print("---> Request Finished <---")
        print(request.description)
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        print("---> Request JSONResponse <---")
        if let data = response.data, let json = String(data: data, encoding: .utf8) {
            print(json)
        }
    }
}
