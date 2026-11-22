gdjs.LobbyCode = {};
gdjs.LobbyCode.localVariables = [];
gdjs.LobbyCode.idToCallbackMap = new Map();
gdjs.LobbyCode.GDLobbyButtonObjects1= [];
gdjs.LobbyCode.GDLobbyButtonObjects2= [];
gdjs.LobbyCode.GDTitleBannerObjects1= [];
gdjs.LobbyCode.GDTitleBannerObjects2= [];
gdjs.LobbyCode.GDLobbyHintObjects1= [];
gdjs.LobbyCode.GDLobbyHintObjects2= [];
gdjs.LobbyCode.GDLobbyFriendsObjects1= [];
gdjs.LobbyCode.GDLobbyFriendsObjects2= [];
gdjs.LobbyCode.GDSoloHintObjects1= [];
gdjs.LobbyCode.GDSoloHintObjects2= [];


gdjs.LobbyCode.eventsList0 = function(runtimeScene) {

{


let isConditionTrue_0 = false;
isConditionTrue_0 = false;
isConditionTrue_0 = gdjs.evtTools.input.isMouseButtonReleased(runtimeScene, "Left");
if (isConditionTrue_0) {
isConditionTrue_0 = false;
/* Unknown instruction - skipped. */}
if (isConditionTrue_0) {
{gdjs.multiplayer.openLobbiesWindow(runtimeScene);
}
}

}


{


let isConditionTrue_0 = false;
isConditionTrue_0 = false;
isConditionTrue_0 = gdjs.multiplayer.hasLobbyGameJustStarted();
if (isConditionTrue_0) {
{gdjs.evtTools.runtimeScene.replaceScene(runtimeScene, "Club", false);
}
}

}


{


let isConditionTrue_0 = false;
isConditionTrue_0 = false;
isConditionTrue_0 = gdjs.evtTools.input.isKeyPressed(runtimeScene, "p");
if (isConditionTrue_0) {
{gdjs.evtTools.runtimeScene.replaceScene(runtimeScene, "Club", false);
}
}

}


};

gdjs.LobbyCode.func = function(runtimeScene) {
runtimeScene.getOnceTriggers().startNewFrame();

gdjs.LobbyCode.GDLobbyButtonObjects1.length = 0;
gdjs.LobbyCode.GDLobbyButtonObjects2.length = 0;
gdjs.LobbyCode.GDTitleBannerObjects1.length = 0;
gdjs.LobbyCode.GDTitleBannerObjects2.length = 0;
gdjs.LobbyCode.GDLobbyHintObjects1.length = 0;
gdjs.LobbyCode.GDLobbyHintObjects2.length = 0;
gdjs.LobbyCode.GDLobbyFriendsObjects1.length = 0;
gdjs.LobbyCode.GDLobbyFriendsObjects2.length = 0;
gdjs.LobbyCode.GDSoloHintObjects1.length = 0;
gdjs.LobbyCode.GDSoloHintObjects2.length = 0;

gdjs.LobbyCode.eventsList0(runtimeScene);
gdjs.LobbyCode.GDLobbyButtonObjects1.length = 0;
gdjs.LobbyCode.GDLobbyButtonObjects2.length = 0;
gdjs.LobbyCode.GDTitleBannerObjects1.length = 0;
gdjs.LobbyCode.GDTitleBannerObjects2.length = 0;
gdjs.LobbyCode.GDLobbyHintObjects1.length = 0;
gdjs.LobbyCode.GDLobbyHintObjects2.length = 0;
gdjs.LobbyCode.GDLobbyFriendsObjects1.length = 0;
gdjs.LobbyCode.GDLobbyFriendsObjects2.length = 0;
gdjs.LobbyCode.GDSoloHintObjects1.length = 0;
gdjs.LobbyCode.GDSoloHintObjects2.length = 0;


return;

}

gdjs['LobbyCode'] = gdjs.LobbyCode;
