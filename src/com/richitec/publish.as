// ActionScript file

import com.richitec.StreamClient;

import flash.events.NetStatusEvent;
import flash.events.StatusEvent;
import flash.media.Camera;
import flash.media.H264Level;
import flash.media.H264Profile;
import flash.media.H264VideoStreamSettings;
import flash.media.Microphone;
import flash.media.Video;
import flash.media.SoundCodec;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.NetStreamPlayOptions;
import flash.net.NetStreamPlayTransitions;

import mx.collections.ArrayList;

import spark.components.ButtonBar;
import spark.components.VideoDisplay;
import spark.events.IndexChangeEvent;

private var _camera:Camera = null;
private var _mic:Microphone = null;

private var _conn:NetConnection = null;
private var _remoteStreamArray:Array = null;

private var localStream:NetStream = null;
private var remoteStream:NetStream = null;

private var localVideo:Video = null;
private var remoteVideo:Video = null;


private function publish():void{
	
	btnPub.enabled = false;
	btnStop.enabled = true;
	
	if (Camera.names.length > 0) { 
		trace("User has at least one camera installed."); 
	} else { 
		trace("User has no cameras installed."); 
	}
	
	var localVideoDisplay:VideoDisplay = this["lcoalVideoDisplay"];
	
	_camera = Camera.getCamera("0");
	if (_camera){
		var width:int = Number(txtIptVideoWidth.text);
		var height:int = Number(txtIptVideoHeight.text);
		var fps:int = Number(txtIptVideoFPS.text);
		var quality:int = Number(txtIptVideoQuality.text);
		
		_camera.addEventListener(StatusEvent.STATUS, cameraEventHandler);
		_camera.setMode(width, height, fps);
		_camera.setQuality(0, quality);
		
		localVideo = new Video(_camera.width, _camera.height);
		localVideo.attachCamera(_camera);
		localVideo.width = localVideoDisplay.width;
		localVideo.height = localVideoDisplay.height;
		localVideoDisplay.addChild(localVideo);
		
		connect();
	} else {
		trace("Cannot get any camera!");
	}
	
	_mic = Microphone.getMicrophone();
	if (_mic){
		_mic.addEventListener(StatusEvent.STATUS, microphoneEventHandler);
		_mic.setUseEchoSuppression(true);
		_mic.codec = SoundCodec.SPEEX;
		_mic.rate = 8;
//		_mic.setLoopBack(true);
	} else {
		trace("Cannot get any microphone!");
	}
}

private function cameraEventHandler(event:StatusEvent):void {
	trace("Camera Event:" + event.code);
}

private function microphoneEventHandler(event:StatusEvent):void {
	trace("Microphone Event:" + event.code);
}

private function connect():void {
	var uri:String = "rtmp://" + txtIpAddr.text + "/" + txtConfId.text;
	_conn = new NetConnection();
	_conn.client = this;
	_conn.addEventListener(NetStatusEvent.NET_STATUS, eventHandler);
	
	try{
		_conn.connect(uri, txtUserId.text);
	}catch (e:ArgumentError){
		trace("Incorrect connet URL");
	}
}

private function eventHandler(event:NetStatusEvent):void {
	trace("Net Status Event : " + event.info.code);
	
	switch (event.info.code) {
		case "NetConnection.Connect.Success":
			connectSuccess();
			break;	

		//deault
		default:
			break;		
	}
}

private function connectSuccess():void {
	localStream = new NetStream(_conn);
	localStream.addEventListener(NetStatusEvent.NET_STATUS, eventHandler);
	localStream.attachCamera(_camera);
	localStream.attachAudio(_mic);
	
	var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
	h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_3_1);
	localStream.videoStreamSettings = h264Settings;
	
	localStream.publish(txtUserId.text, txtPubType.text);		
}

/**
 * 
 *
 * */
 private function disconnect():void {
	 if (null != localStream) {
		 localVideo.clear();
		 lcoalVideoDisplay.removeChild(localVideo);
		 localStream.close();
	 }
	 if (null != _conn) {
		 _conn.close();
	 }
	 
	 btnPub.enabled = true;
	 btnStop.enabled = false;
 }


public function joinMessage(userId:String):void {

}

public function unjoinMessage(userId:String):void {

}

public function streamStartMessage(streamName:String):void {

}

public function streamCloseMessage(streamName:String):void {

}

public function streamListMessage(streamList:Array):void {
	
}


