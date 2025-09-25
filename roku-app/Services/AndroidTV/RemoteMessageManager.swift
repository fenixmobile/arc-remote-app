import Foundation

class RemoteMessageManager {
    static let shared = RemoteMessageManager()
    
    private func createMessage(payload: Remote_RemoteMessage) -> Data? {
        do {
            return try payload.serializedData()
        } catch {
            print("Error serializing message: \(error)")
            return nil
        }
    }

    func createRemoteConfigure() -> Data? {
        var message = Remote_RemoteMessage()
        var config = Remote_RemoteConfigure()
        config.code1 = 622
        var deviceInfo = Remote_RemoteDeviceInfo()
        deviceInfo.model = "Universal Remote"
        deviceInfo.vendor = ""
        deviceInfo.unknown1 = 1
        deviceInfo.unknown2 = "1"
        deviceInfo.packageName = "androidtv-remote"
        deviceInfo.appVersion = "1.0.0"
        config.deviceInfo = deviceInfo
        message.remoteConfigure = config
        return createMessage(payload: message)
    }

    func createRemoteSetActive(active: Int32) -> Data? {
        var remoteSetActive = Remote_RemoteSetActive()
        remoteSetActive.active = active
        var message = Remote_RemoteMessage()
        message.remoteSetActive = remoteSetActive
        return createMessage(payload: message)
    }

    func createRemotePingResponse(val1: Int32) -> Data? {
        var pingResponse = Remote_RemotePingResponse()
        pingResponse.val1 = val1
        var message = Remote_RemoteMessage()
        message.remotePingResponse = pingResponse
        return createMessage(payload: message)
    }
    
    func createRemoteKeyInject(keyCode: Remote_RemoteKeyCode) -> Data? {
        var remoteKeyInject = Remote_RemoteKeyInject()
        remoteKeyInject.keyCode = keyCode
        remoteKeyInject.direction = .short
        var message = Remote_RemoteMessage()
        message.remoteKeyInject = remoteKeyInject
        return createMessage(payload: message)
    }

    func parse(data: Data) -> Remote_RemoteMessage? {
        do {
            return try Remote_RemoteMessage(serializedData: data)
        } catch {
            print("Error parsing message: \(error)")
            return nil
        }
    }
}
