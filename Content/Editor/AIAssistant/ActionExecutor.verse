# AI Assistant Action Executor for UEFN
# ponytail: minimal parser, JSON subset only. Full parser if AI returns complex nested structures.

using { /UnrealEngine/UnrealEngine.Editor }
using { /UnrealEngine/UnrealEngine.Editor.EditorAssetLibrary }
using { /UnrealEngine/UnrealEngine.Editor.LevelEditorActorSubsystem }
using { /VerseEngine/Verse }

# Minimal JSON value representation
JsonValue := struct {
    StringValue: string = ""
    NumberValue: float = 0.0
    BoolValue: bool = false
    ArrayValue: array<JsonValue> = array{}
    ObjectValue: map<string,JsonValue> = map{}
    IsString: bool = false
    IsNumber: bool = false
    IsBool: bool = false
    IsArray: bool = false
    IsObject: bool = false
}

# Action parsed from AI response
Action := struct {
    ActionType: string = ""
    DeviceClass: string = ""
    Location: vector3 = vector3{}
    Rotation: rotator = rotator{}
    Properties: map<string,string> = map{}
}

# Parses AI JSON response and executes editor actions
ActionExecutor := class<editor>:

    # Get all actors in the level as context for AI
    GetLevelContext() : string:
        AllActors := EditorLevelEditorActorSubsystem.GetAllLevelActors()
        Context: string = "Current level actors:\n"
        
        for (Actor: AllActors):
            ActorName := GetName(Actor)
            ActorClass := GetClass(Actor)
            ActorLocation := GetActorLocation(Actor)
            Context += ActorName & " (" & ActorClass & ") at " & ToString(ActorLocation) & "\n"
        
        return Context

    # Parse and execute AI response JSON
    Execute(AIResponse: string) <suspends>: string:
        VerseString := AIResponse
        VerseCode := ExtractField("verse_code", VerseString)
        Actions := ExtractActions(VerseString)
        Explanation := ExtractField("explanation", VerseString)
        
        LogOutput: string = ""
        
        if (Explanation /= ""):
            LogOutput += Explanation & "\n\n"
        
        if (VerseCode /= ""):
            LogOutput += "Verse code generated:\n" & VerseCode & "\n\n"
        
        for (Action: Actions):
            LogOutput += ExecuteAction(Action)
        
        return LogOutput

    # Extract a string field from JSON
    ExtractField(Field: string, Json: string) : string:
        SearchPattern := "\"" & Field & "\": \""
        StartIdx := FindSubstr(SearchPattern, Json)
        if (StartIdx < 0):
            return ""
        
        ValueStart := StartIdx + Length(SearchPattern)
        ValueEnd := FindSubstr("\"", Json, ValueStart)
        if (ValueEnd < 0):
            return ""
        
        return Substr(Json, ValueStart, ValueEnd - ValueStart)

    # Extract actions array from JSON
    ExtractActions(Json: string) : array<Action>:
        Actions: array<Action> = array{}
        
        SearchPattern := "\"actions\": ["
        ArrayStart := FindSubstr(SearchPattern, Json)
        if (ArrayStart < 0):
            return Actions
        
        ArrayEnd := FindSubstr("]", ArrayStart + Length(SearchPattern))
        if (ArrayEnd < 0):
            return Actions
        
        ArrayContent := Substr(Json, ArrayStart + Length(SearchPattern), ArrayEnd - ArrayStart - Length(SearchPattern))
        
        # Simple split by "}," for each action object
        ActionStrings := SplitString(ArrayContent, "},")
        
        for (ActionStr: ActionStrings):
            CleanStr := TrimString(ActionStr, " {}")
            if (CleanStr /= ""):
                NewAction: Action = Action{}
                NewAction.ActionType := ExtractField("type", CleanStr)
                NewAction.DeviceClass := ExtractField("device_class", CleanStr)
                
                LocX := ExtractNumberField("x", CleanStr)
                LocY := ExtractNumberField("y", CleanStr)
                LocZ := ExtractNumberField("z", CleanStr)
                NewAction.Location := vector3{X=LocX, Y=LocY, Z=LocZ}
                
                Actions.append(NewAction)
        
        return Actions

    # Extract a number field from JSON
    ExtractNumberField(Field: string, Json: string) : float:
        SearchPattern := "\"" & Field & "\": "
        StartIdx := FindSubstr(SearchPattern, Json)
        if (StartIdx < 0):
            return 0.0
        
        ValueStart := StartIdx + Length(SearchPattern)
        ValueEnd := FindSubstr(",", Json, ValueStart)
        if (ValueEnd < 0):
            ValueEnd := FindSubstr("}", Json, ValueStart)
        if (ValueEnd < 0):
            return 0.0
        
        ValueStr := Substr(Json, ValueStart, ValueEnd - ValueStart)
        return ToFloat(ValueStr)

    # Execute a single action
    ExecuteAction(Action: Action) <suspends>: string:
        if (Action.ActionType = "spawn_device"):
            return SpawnDevice(Action)
        else if (Action.ActionType = "modify_actor"):
            return ModifyActor(Action)
        else if (Action.ActionType = "delete_actor"):
            return DeleteActor(Action)
        else if (Action.ActionType = "create_folder"):
            return CreateFolder(Action)
        
        return "Unknown action: " & Action.ActionType & "\n"

    # Spawn a device at location
    SpawnDevice(Action: Action) <suspends>: string:
        AssetPath := "/Game/" & Action.DeviceClass
        
        if (not EditorAssetLibrary.IsAssetLoaded(AssetPath)):
            EditorAssetLibrary.LoadAsset(AssetPath)
        
        SpawnedActor := EditorLevelEditorActorSubsystem.SpawnActorFromAsset(
            Asset = EditorAssetLibrary.LoadAsset(AssetPath),
            Location = Action.Location,
            Rotation = Action.Rotation
        )
        
        if (SpawnedActor = valid):
            return "Spawned: " & Action.DeviceClass & "\n"
        
        return "Failed to spawn: " & Action.DeviceClass & "\n"

    # Modify an existing actor
    ModifyActor(Action: Action) <suspends>: string:
        # Find actor by name
        AllActors := EditorLevelEditorActorSubsystem.GetAllLevelActors()
        
        for (Actor: AllActors):
            if (GetName(Actor) = Action.DeviceClass):
                SetActorLocation(Actor, Action.Location)
                SetActorRotation(Actor, Action.Rotation)
                return "Modified: " & Action.DeviceClass & "\n"
        
        return "Actor not found: " & Action.DeviceClass & "\n"

    # Delete an actor
    DeleteActor(Action: Action) <suspends>: string:
        AllActors := EditorLevelEditorActorSubsystem.GetAllLevelActors()
        
        for (Actor: AllActors):
            if (GetName(Actor) = Action.DeviceClass):
                EditorLevelEditorActorSubsystem.DestroyActor(Actor)
                return "Deleted: " & Action.DeviceClass & "\n"
        
        return "Actor not found: " & Action.DeviceClass & "\n"

    # Create folder in content browser
    CreateFolder(Action: Action) <suspends>: string:
        FolderPath := "/Game/" & Action.DeviceClass
        EditorAssetLibrary.MakeDirectory(FolderPath)
        return "Created folder: " & FolderPath & "\n"
