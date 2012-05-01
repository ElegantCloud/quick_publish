package com.richitec
{
	public class StreamClient
	{
		public function StreamClient(){
			//
		}
		
		public function onPlayStatus(info:Object):void {
			trace("Play Status : " + info.code);
			if(info.code == "NetStream.Play.TransitionComplete") {
				trace("switched playback to new stream : " + info.details);
			} else if (info.code == "NetStream.Play.Complete") {
				
			}
		}
	}
}