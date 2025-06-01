//
//  KakaoMapView.swift
//  Grayzone
//
//  Created by Wonbi on 6/1/25.
//

import SwiftUI

import KakaoMapsSDK

struct KakaoMapRepresentable: UIViewRepresentable {
    @Binding var draw: Bool
    let x: Double
    let y: Double
    
    func makeUIView(context: Context) -> KMViewContainer {
        let view: KMViewContainer = KMViewContainer()
        view.sizeToFit()
        view.isUserInteractionEnabled = false
        context.coordinator.createController(view)
        context.coordinator.controller?.prepareEngine()
        
        return view
        
    }
        
    func updateUIView(_ uiView: KMViewContainer, context: Context) {
        guard let controller = context.coordinator.controller else { return }
        
        if draw {
            if !controller.isEngineActive {
                DispatchQueue.main.async {
                    controller.activateEngine()
                }
            }
        } else {
            if controller.isEngineActive {
                controller.pauseEngine()
                controller.resetEngine()
            }
        }
    }
    
    /// Coordinator 생성
    func makeCoordinator() -> KakaoMapCoordinator {
        return KakaoMapCoordinator(x: x, y: y)
    }
    
    class KakaoMapCoordinator: NSObject, MapControllerDelegate {
        let longitude: Double
        let latitude: Double
        
        var controller: KMController?
        var first: Bool
        
        init(x: Double, y: Double) {
            first = true
            let coordinate = EPSGConverter.convert(x: x, y: y)
            self.longitude = coordinate.longitude
            self.latitude = coordinate.latitude
            super.init()
        }
        
         // KMController 객체 생성 및 event delegate 지정
        func createController(_ view: KMViewContainer) {
            controller = KMController(viewContainer: view)
            controller?.delegate = self
        }
        
         // KMControllerDelegate Protocol method구현
         
          /// 엔진 생성 및 초기화 이후, 렌더링 준비가 완료되면 아래 addViews를 호출한다.
          /// 원하는 뷰를 생성한다.
        func addViews() {
            let defaultPosition: MapPoint = MapPoint(longitude: longitude, latitude: latitude)
            let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 16)
            
            controller?.addView(mapviewInfo)
        }

        //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
        func addViewSucceeded(_ viewName: String, viewInfoName: String) {
            print("👀 \(#function)")
            print("OK") //추가 성공. 성공시 추가적으로 수행할 작업을 진행한다.
        }
    
        //addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
        func addViewFailed(_ viewName: String, viewInfoName: String) {
            let message = controller?.getStateDescMessage() ?? ""
            print("👀 \(#function):: \(message) ")
            print("Failed")
        }
        
        /// KMViewContainer 리사이징 될 때 호출.
        func containerDidResized(_ size: CGSize) {
            print("👀 \(#function)")
            let mapView: KakaoMap? = controller?.getView("mapview") as? KakaoMap
            mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
            if first {
                let cameraUpdate: CameraUpdate = CameraUpdate.make(target: MapPoint(longitude: 127.108678, latitude: 37.402001), zoomLevel: 10, mapView: mapView!)
                mapView?.moveCamera(cameraUpdate)
                first = false
            }
        }
    }
}


struct KakaoMapCardView: View {
    @State var draw: Bool = false
    let coordinate: Coordinate
    
    var body: some View {
        KakaoMapRepresentable(draw: $draw, x: coordinate.x, y: coordinate.y)
            .onAppear { draw = true }
            .onDisappear { draw = false }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
