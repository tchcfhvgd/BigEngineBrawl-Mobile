package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import flixel.FlxCamera;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
import flixel.system.FlxSound;
import Controls;

using StringTools;

class BebAwardsState extends MusicBeatState
{
	var grpOptions:FlxSpriteGroup;
    var bg:FlxSprite;
    var topham:FlxSprite;
    var overlay:FlxSprite;
    var overlay2:FlxSprite;
    var allowedToChange:Bool = false;
    var curSelected:Int = 0;
    var camFollow:FlxObject;
	var camFollowPos:FlxObject;
    var cursorSprite:FlxSprite;
    var cursorSprite2:FlxSprite;
	var backButton:FlxSprite;

    var photos:FlxSpriteGroup;
    var inPhoto:Bool;

    var photoBG:FlxSprite;
    var photoZoom:FlxSprite;

    var tophamState:Int = 0;

    var tophamSound:FlxSound = new FlxSound();

    var music2:FlxSound = new FlxSound();

    var achieves:Array<String> = [];

    var achieveDescs:Array<Dynamic> = [];

    var achieveName:FlxText;
    var achieveDesc:FlxText;

    var fatHint:FlxSprite;
    var fatHintSound:FlxSound;
    var tweening:Bool = false;

    override function create(){
        #if desktop
		DiscordClient.changePresence("In Sir Topham Hatt's Office (Awards Menu)", null);
		#end

        for(i in 0...Achievements.achievementsStuff.length-2)
        {
            if (Achievements.isAchievementUnlocked(Achievements.achievementsStuff[i][2]))
            {
                achieves.push(Achievements.achievementsStuff[i][2]);
                achieveDescs.push([Achievements.achievementsStuff[i][0], Achievements.achievementsStuff[i][1]]);
            }
            else
            {
                if (Achievements.achievementsStuff[i][2] != 'awardloathed')
                {
                    achieves.push('awardempty');
                    achieveDescs.push([Achievements.achievementsStuff[i][0], '????']);
                }
            }
        }
        trace(achieves);

        music2 = FlxG.sound.load(Paths.music('beb_awards_angry'), 0);
        music2.looped = true;
        music2.play();
        FlxG.sound.playMusic(Paths.music('beb_awards'), 0);
        FlxG.sound.music.fadeIn(1, 0, 0.7);

        BebMainMenu.previousState = 'awards';

        
		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		        
        bg = new FlxSprite().loadGraphic(Paths.image('awards/tophamoffice','menu'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.setGraphicSize(Std.int(FlxG.width));
        bg.screenCenter();
        add(bg);

        photos = new FlxSpriteGroup();
        var xFuckShit:Int = 0;
        for (i in 0...achieves.length)
            {
                
                var achieveImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image('award portraits/${achieves[i]}','secretStuff'));
                achieveImage.scale.x = 0.2;
                achieveImage.scale.y = 0.2;
                achieveImage.updateHitbox();
                achieveImage.x = 10 + achieveImage.width * i;
                if (i > 0)
                    achieveImage.x += 15 * i;
                achieveImage.y += 25;
                if (xFuckShit > 4)
                {
                    achieveImage.x = 10 + achieveImage.width * (i - 5);
                    if (i - 5 > 0)
                        achieveImage.x += 15 * (i - 5);
                    achieveImage.y += achieveImage.height;
                }
                
                xFuckShit++;
                photos.add(achieveImage);
            }

        if(Achievements.isAchievementUnlocked(Achievements.achievementsStuff[Achievements.achievementsStuff.length-1][2]))
        {
            achieves.push(Achievements.achievementsStuff[Achievements.achievementsStuff.length-1][2]);
            achieveDescs.push([Achievements.achievementsStuff[Achievements.achievementsStuff.length-1][0], Achievements.achievementsStuff[Achievements.achievementsStuff.length-1][1]]);

            var achieveImage:FlxSprite = new FlxSprite(FlxG.width/4*3 - 175, FlxG.height/2 - 225).loadGraphic(Paths.image('award portraits/${achieves[achieves.length-1]}','secretStuff'));
            achieveImage.scale.x = 0.2;
            achieveImage.scale.y = 0.2;
            achieveImage.updateHitbox();
            photos.add(achieveImage);
        }
        else if(Achievements.isAchievementUnlocked(Achievements.achievementsStuff[Achievements.achievementsStuff.length-2][2]))
        {
            achieves.push(Achievements.achievementsStuff[Achievements.achievementsStuff.length-1][2]);
            achieveDescs.push([Achievements.achievementsStuff[Achievements.achievementsStuff.length-1][0], Achievements.achievementsStuff[Achievements.achievementsStuff.length-1][1]]);

            var achieveImage:FlxSprite = new FlxSprite(FlxG.width/4*3 - 175, FlxG.height/2 - 225).loadGraphic(Paths.image('award portraits/${achieves[achieves.length-1]}','secretStuff'));
            achieveImage.scale.x = 0.2;
            achieveImage.scale.y = 0.2;
            achieveImage.updateHitbox();
            photos.add(achieveImage);
        }

            add(photos);

            topham = new FlxSprite().loadGraphic(Paths.image('awards/topham1','menu'));
            topham.antialiasing = ClientPrefs.globalAntialiasing;
            topham.setGraphicSize(Std.int(FlxG.width));
            topham.screenCenter();
            add(topham);

        cursorSprite = new FlxSprite().loadGraphic(Paths.image('ui/cursor'));
        cursorSprite2 = new FlxSprite().loadGraphic(Paths.image('ui/cursor2'));
        FlxG.mouse.visible = true;

        backButton = new FlxSprite().loadGraphic(Paths.image('freeplay/back_button',"menu"));
		backButton.setGraphicSize(Std.int(backButton.width * 0.8));
		backButton.updateHitbox();
		backButton.x = FlxG.width - backButton.width - 10;
		backButton.y = FlxG.height - backButton.height - 10;
        backButton.alpha = 0;
        FlxTween.tween(backButton, {alpha: 1}, 0.25);
		add(backButton);

        overlay = new FlxSprite().loadGraphic(Paths.image('awards/awardsoverlaymultiply','menu'));
		overlay.antialiasing = ClientPrefs.globalAntialiasing;
        overlay.setGraphicSize(Std.int(FlxG.width));
        overlay.screenCenter();
        overlay.blend = MULTIPLY;
        add(overlay);

        overlay2 = new FlxSprite().loadGraphic(Paths.image('awards/awardsoverlay2add','menu'));
		overlay2.antialiasing = ClientPrefs.globalAntialiasing;
        overlay2.setGraphicSize(Std.int(FlxG.width));
        overlay2.screenCenter();
        overlay2.blend = ADD;
        add(overlay2);


        photoBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        photoBG.alpha = 0;
        add(photoBG);

        photoZoom = new FlxSprite().loadGraphic(Paths.image('award full imgs/${achieves[0]}','secretStuff'));
        photoZoom.alpha = 0;
        add(photoZoom);

        achieveName = new FlxText(0, 0, 0, '', 46);
        achieveName.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		achieveName.alpha = 0;
		achieveName.borderSize = 2;

        achieveDesc = new FlxText(0, 0, 0, '', 46);
        achieveDesc.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		achieveDesc.alpha = 0;
		achieveDesc.borderSize = 2;

        fatHint = new FlxSprite().loadGraphic(Paths.image('awards/hint_button','menu'));
        fatHint.setGraphicSize(Std.int(fatHint.width * 0.6));
        fatHint.updateHitbox();
        fatHint.y = FlxG.height / 2 - fatHint.height/2;
        fatHint.x = FlxG.width / 8*7 - fatHint.width/2 - 50;
        fatHint.alpha = 0;
        fatHint.visible = false;
        add(fatHint);

        add(achieveName);
        add(achieveDesc);

        super.create();
    }

    var targetY:Float = 0;

    override function update(elapsed:Float){

        if (FlxG.keys.justPressed.SPACE)
            {
                #if debug
                
                for(i in 0...Achievements.achievementsStuff.length)
                    {
                        Achievements.unlockAchievement(Achievements.achievementsStuff[i][2]);
                    }

                #end
            }
        if (!inPhoto)
        {
            if (controls.BACK || FlxG.mouse.justPressedRight) {
                allowedToChange = false;

                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new BebMainMenu());
                FlxG.sound.music.fadeOut(1, 0);
                

            }

            for (i in 0...photos.members.length)
                {
                    if (FlxG.mouse.overlaps(photos.members[i]))
                        {
                            if (FlxG.mouse.justPressed)
                            {
                                inPhoto = true;
                                if(Achievements.isAchievementUnlocked(Achievements.achievementsStuff[i][2]))
                                    photoZoom.loadGraphic(Paths.image('award full imgs/${achieves[i]}','secretStuff'));
                                else
                                    photoZoom.makeGraphic(2000, 2000, FlxColor.BLACK);
                                photoZoom.setGraphicSize(0, Std.int(FlxG.height));
                                photoZoom.screenCenter();
                                achieveName.text = achieveDescs[i][0];
                                achieveName.x = FlxG.width/2 - achieveName.width /2;
                                achieveName.y = FlxG.height - achieveName.height - 55;
                                achieveDesc.text = achieveDescs[i][1];
                                achieveDesc.x = FlxG.width/2 - achieveDesc.width /2;
                                achieveDesc.y = FlxG.height - achieveDesc.height - 5;
                                tweening = true;
                                if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[i][2]))
                                    {
                                        fatHintSound = new FlxSound().loadEmbedded(Paths.whistleHidden('${Achievements.achievementsStuff[i][2]}hint'));
                                        fatHint.visible = true;
                                        FlxTween.tween(fatHint, {alpha: 0.6}, 0.25);
                                    }
                                FlxTween.tween(photoZoom, {alpha: 1}, 0.25, {onComplete: function(lol:FlxTween){tweening = false;}});
                                FlxTween.tween(photoBG, {alpha: 0.75}, 0.25);
                                FlxTween.tween(achieveName, {alpha: 1}, 0.25);
                                FlxTween.tween(achieveDesc, {alpha: 1}, 0.25);
                            }
                        }
                    
                    if (FlxG.mouse.overlaps(photos.members[i]))
                        {
                            changeCursor(true);
                            break;
                        }
                    else
                        changeCursor(false);
                        
                        
                }


                if (FlxG.mouse.overlaps(backButton))
                    {
                        changeCursor(true);
                        backButton.loadGraphic(Paths.image('freeplay/back_button_selected', 'menu'));
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.sound.play(Paths.sound('cancelMenu'));
                            MusicBeatState.switchState(new BebMainMenu());
                            FlxG.sound.music.fadeOut(1, 0);
                        }
                    }
                else
                    {
                        backButton.loadGraphic(Paths.image('freeplay/back_button', 'menu'));
                    }

                    if (FlxG.mouse.overlaps(topham) && FlxG.mouse.x > (FlxG.width / 2 - 150) && FlxG.mouse.x < (FlxG.width / 2 + 50) && FlxG.mouse.y > (FlxG.height / 2 - 100) && FlxG.mouse.y < (FlxG.height / 2 + 100))
                        {
                            changeCursor(true);
                            
                            if (FlxG.mouse.justPressed && !tophamSound.playing)
                            {
                                if (!ClientPrefs.fatassPlayed)
                                {
                                    if (tophamState < 3)
                                    {
                                        tophamState++;
                                        topham.loadGraphic(Paths.image('awards/topham${tophamState}', 'menu'));
                                    }
                                    if (tophamState <= 2)
                                    {
                                        tophamSound = FlxG.sound.load(Paths.sound('cnd/fatcontroller_unlock${tophamState}', 'menu'));
                                        tophamSound.play();
                                    }
                                    if (tophamState == 2)
                                        {
                                            music2.fadeIn(1, 0, 0.7);
                                            FlxG.sound.music.fadeOut(1, 0);
                                        }
                                    if (tophamState == 3)
                                        {
                                            backButton.visible = false;
                                            FlxG.mouse.visible = false;
                                            loadSong();
                                        }
                                }
                                else
                                {
                                    topham.loadGraphic(Paths.image('awards/topham3', 'menu'));
                                    backButton.visible = false;
                                    FlxG.mouse.visible = false;
                                    loadSong();
                                }
                            }
                        }
        
        }
        else
            {
                if (FlxG.mouse.justPressed)
                    {
                        if (FlxG.mouse.overlaps(fatHint) && !tweening && fatHint.visible)
                        {
                            fatHintSound.play();
                        }
                        
                        else
                        {

                            FlxTween.tween(fatHint, {alpha: 0}, 0.25, {onComplete: function(lol:FlxTween){fatHint.visible = false;}});
                            FlxTween.tween(photoZoom, {alpha: 0}, 0.25);
                            FlxTween.tween(photoBG, {alpha: 0}, 0.25, {onComplete: function(lol:FlxTween){inPhoto = false; tweening = false;}});
                            FlxTween.tween(achieveName, {alpha: 0}, 0.25);
                            FlxTween.tween(achieveDesc, {alpha: 0}, 0.25);
                        }
                    }
                if (FlxG.mouse.overlaps(fatHint) && !tweening)
                        
                    fatHint.alpha = 1;
                        
                else if (!FlxG.mouse.overlaps(fatHint) && !tweening)
                    fatHint.alpha = 0.6;
            }
        

        super.update(elapsed);

    }

    function changeCursor(value:Bool)
        {
            if (value)
                {
                    FlxG.mouse.load(cursorSprite2.pixels);
                }
            if (!value)
                {
                    FlxG.mouse.load(cursorSprite.pixels);
                }
        }

        function loadSong()
            {
                persistentUpdate = false;
                var songLowercase:String = Paths.formatToSongPath('confusion-and-delay');
                var poop:String = Highscore.formatSong(songLowercase, ClientPrefs.difficulty);
                FlxTransitionableState.skipNextTransIn = true;
			    FlxTransitionableState.skipNextTransOut = true;
                /*#if MODS_ALLOWED
                if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
                #else
                if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
                #end
                    poop = songLowercase;
                    curDifficulty = 1;
                    trace('Couldnt find file');
                }*/
                trace(poop);
    
                PlayState.SONG = Song.loadFromJson(poop, songLowercase);
                PlayState.isStoryMode = false;
                PlayState.storyDifficulty = ClientPrefs.difficulty;
    
                //trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
                LoadingState.loadAndSwitchState(new PlayState());
    
                FlxG.sound.music.volume = 0;
                        
                //destroyFreeplayVocals();
            }
}

    /// ((((((((((((((((((#########*#%@@@%%@%%@@@@@@@@@@@@@@@@@@@@@@@@@&&& /@&&(%%@@@@@@@@@@@@@@@@@@@@@@@@@%((...##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((((((((((((((((((#########*#%@@@%%@%%@@@@@@@@@@@@@@@@@@@@@@@@@&@@ /@&&#%%@@@@@@@@@@@@@@@@@@@@@@@@@%((...#%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// (((((((((((((((((((########*#%@@@%%@%%@@@@@@@@@@@@@@@@@@@@@@@@@&@@&&@&&###@@@@@@@@@@@@@@@@@@@@@@@@@%#(...##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// (((((((((((((((((((########*#%@@@%%@%%@@@@@@@@@@@@@@@@@@@@@@@@@&@@#&@&&###@@@@@@@@@@@@@@@@@@@@@@@@@&##..,##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// (((((((((((((((((((######((*#&@@@%%@%%@@@@@@@@@@@@@@@@@@@@@@@@@@&&&@@&&###@@@@@@@@@@@@@@@@@@@@@@@@@&##,,,##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// (((((((((((((((((((######((/%&@@@%%@%%@@@@@@@@@@@@@@@@@@@@@@@@@@&&&@@&&###@@@@@@@@@@@@@@@@@@@@@@@@@&##**,##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// (((((((((((((((((((######((/%@@@@%%@%%@@@@@@@@@@@@@@@@@@@@@@@@@@&&&@@&&###@@@@@@@@@@@@@@@@@@@@@@@@@@##**,#%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// (((((((((((((((((((######((/%&@@@%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@&&&#%@&&###@@@@@@@@@@@@@@@@@@@@@@@@@@##/**#%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// (((((((((((((((((((######((/#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&@@&&###@@@@@@@@@@@@@@@@@@@@@@@@@@##//*##&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((((((((((((((((((#######((*#&@@%((#%%&@@@@@@@@@@@@@@@@@@@@@@@@&&&&@@&&###@@@@@@@@@@@@@@@@@@@@@@@@@@%#//*(#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((((((((((((((((#########///%@@@%#############((((((####%%&&&@@@@@@@@@&###@@@@@@@@@@@@@@@@@@@@@@@@@@##(/*##%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ,,***///((((((########((*/(&@@&%((((((((((((###########(((((####%%%&@@&###@@@@@@@@@@@@@@@@@@@@@@@@@@##(/*##%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// &&%%%###########%%#%%&@@@&&#((((((((((((((((((((((((########&@@@@@@@@@@&((%@@@@@@@@@@@@@@@@@@@@@@@@&###((###%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// &&&@@%%#######%%&&&&&%##(((((((((((((((((((((((((#######%&@@@@@@@@@@@@@@%%###%&@@@@@@@@@@@@@@@@@@@@&########%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ########((((((((((((((((((((((((((((((((((((######%%@@@@@@@@@@@@@@@@@@@@@@@@@@&&%%#%%&@@@@@@@@@@@&&#%%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// #####((((((((((((((((((((((((((((((((((((#####%&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%#((/*****///(((###&&@@@@@@&&&@@&&&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((((((((((((((((((((((((((((((((((((((######&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%/*,.....,.,,,,,,**/*****/%%@@@@@@%%@%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((///***,,,,,,,,,,,***//(((((((((((######@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&/*...,,,,,,,,,,,,,,,,,,..,,*/////*//%&@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// %%%####((((((///***,,,,,,,,,****/(((((#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#/,..,,,,,,,,,,,,,,,,,,,,,,,,,,,,*///***(%@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// @@@@@@@@@@@@@@@&&&%#####(((((((((///&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%,..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,**//**&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// %%%%%%%%%%&&&&&@@@@@@&@@@@@@&&&&&&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&*,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*/(@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ################%&@%%######%%%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&,,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.*#@@(**#@@@@&@@&&&&&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// //(((((######((((%@&%###%&&@@@&&%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/*.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*#/////*((@@@@@@&&&&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// /((((((/(((((#%&@&&%%%@@@@@&%#(#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&@@@%#..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*///**&@@@@&@@&&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// %%#####%%%%###%%@@@@@&##(((###@@@@@%(((((((((((#####################%%%%&&%%%%%###(&&@@@/,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,**//*/#@@@&&&@&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// &&&&&&&&&&&&&@@@&%###(######%%@@@@@&%%%%####((((((///////////////////(((((//////*/#@@@##.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.,,///*(#@@@&&@&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ///((##%%%@&&#((((##########&@@@@@@@@@@@@@@@@&&%%%######((((///*****************(#@@@%..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,...,,,,,,,,,,,,,,,,,,,,,,,,,*//*//@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((((((//,,,((##############&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&%%%%####((((//*//@@@&&.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.,,&##.,,,,,,,,,,,,,,,,,,,,,,..,*//**#%@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((((((((//*((##############&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&%%###(#%@@@((.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.,*&&@**.,,,,,,,,,,,,,,,,,,,,,,,,,*****/(@@@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// #######(((/##############%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%&@@@%..,,,,,,,,,,,,,,,,,,,,,,,,,,..,(%@@@@@&,,,,,,,,,,,,,,,,,,,,,....**#&&@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/##############&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*..,,,,,,,,,,,,,,,,,,,,,,.,,/%%@@@@@@&&(..,,,,,,,,,,,,,,,,,*/(%%@@@&&%%##((&@@@%#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/##############&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%#.,,,,,,,,,,,,,,,,,,,,...,(@@@@@%#(**,..........,,,,,,,..#%@@@@@@%,,.,,*//*/#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/##############@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@**.,,,,,,,,,,,,,,,,,,,///**.......,,*/(%%&@@@@@@&#,,,,,,..*%@@@@@@#..,,,///**(@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/#############%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,,.,,,,,,,,,,,,,,,,,,,,.....,,*((%&@@@@@@@@@@@@@@@,,.,,,,,,#&@@@@@(..,,,///**/@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/#############%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%..,,,,,,,,,,,,,,,...**#%@@@@@@@@@@&&#((**,,,......,,,,,,,,,..%&@//.,,,,,**////**%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/#############%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#..,,,,,,,,,,,,,*/##%&&%&@@@@@@@@@@#(.....,,,,,,,,,,,,,,,,,,,,,*#@@%((,,.,,*///**/@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((####((((/#############%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%(..,,,,,,,,,.,*##/,,..../%@@@@@@@@@(*..,,,,,,,,,,,,,,,,,,,,,,,,,.,,(@@@%%,,,**///*##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/#############%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%(..,,,,,,,,,,,,,,,,,,,,,,,%&@@@@@@/,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,...(#@&(,,///*//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/#############%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#/..,,,,,,*//((((((((((((((((#%%&##...,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..&&@***//*//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/#############%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#/..,,,,,,,,,,,..........,,,,,***//(((,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..*#@##*//*//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/##############@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#/..,,,,,,,,,,,,,,,,,,,,,,,,,,...,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,(@%%*//*//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/##############&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#/..,,,,,,,,,......,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.,,,,,,,,,,,,,...,,,***/%@%#,//*((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/##############%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#/..,,,,,,,,,#%&@@@&&%((*,...,,,,,,,,,,,,,,,,,,,,,**//*********////////*//@@@,,*//*%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/################@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%/..,,,,,,,,,...,,#@@@@@@&%(/,..,,,,,,,,,,,,,,,,,.,,**/**///////////***(&&@%(..*///&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/################%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#..,,,,,,,,,,,,,,,,,%@@@@@///##*..,,,,,,,,,,,,,,,,,.,,((%%%%%%%%&@@@@@@(/..,,,/**#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(((/################%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&..,,,,,,,,,,,,,,,,,./(@@@@&/..,,,,,,,,,,,,,,,,,,,,,,,..,//#%%%%%%%#//,..,,,,,///&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(#((#############%%%%&&@@@##%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*,.,,,,,,,,,,,,,,,,,,,.*/@@@@@/..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,***##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((#####(##&%%######%%%&&&%%#((%&@@@###&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%(.,,,,,,,,,,,,,,,,,,,,,,..,##@@@&(/,,...,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,**/(@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ######((##%&&%%%%%%&&&%%#(((%%@@@@@&###%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%,..,,,,,,,,,,,,,,,,,,,,,,.../%%@@@&%(**,.....,,,,,,,,,,,,,,,,,,,,,,,,,,*/*/&@@@##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ######((##&&&&&&%##((#&&@@@@&&&&&@@@@@#####%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#..,,,,,,,,,,,,,,,,,,,,,,,,,,,,...**(%%@@@@@@&%#((///***,,,,,,,,,,,,,,*//@@@@@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// ((((((((((&&&%####%&&@@@@&&&&&&&&&&@@@@%######%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@**.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.....,**(##%&&&&&&&&&&&%%#((**,,,,***(%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// @@@@@@@&&&&%%@@@@@@&&&&&&&&&&&&&&&&&&&@@@@&%########&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,...........,,,,,*//&@@@@@@@%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// &&&&&&&&@@@@@@&&&&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&%#######%&&@@@@@@@@@@@@@@@@@@@@@@@@@@,,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,***#@@@@@@@@%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// &&&&&&&&@@@@@@@@@@@@@@@@@@@&&&&&&&&&&&@@@@@@@@@@@@@@&&%###((#%%&@@@@@@@@@@@@@@@@@@@@@@%%.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.,,***##@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    /// @@@@@@@@&&&%%%%%&&&@@@@@@@@%##(((((((((((((((((##%@@@@@@@@@@@&&%######%&@@@@@@@@@@@@@@@@@(*..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..,,***/&&@@@%*,......//&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%@@@@@@
    /// %%#(/**,,,,,,,,,,,,,,*((%@@@@@&&%###########((((((((%&@@@@@@@@@@@@@&&%%###%&&@@@@@@@@@@@@@@*,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,***(#&@@@##******,,,..,%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@%#(@@@@@@
    /// /(((((((((((((((((((((((/**,,,(#&@@@&&%###############(((#&&@@@@@@@@@@@@@@@@@@@&&&&&&@@@@@@@@@**.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..,,******((&@@@@@//**************,..,#@@@@##@###@@@@@@@@@@@@@&@@&&#@@@@@@
    /// ((#######################(((((//***/%%@@@%%####################&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%*,..,,,,,,,,,,,,,,,,,,,*******/((%@@@@@@%#*(@//*****************,,.%&@@@%@@#@@@@@@@@@@@@@&@@&&%@@@@@@
    /// ##############################(((((*,,/%&@@@%%##################%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%/**,,******************//#%@@@@@@@@@@&%*(@//******************,,,*&@@@##@@@@@@@@@@@@@@&@@@&&@@@@@@
    /// (((((((((((((((((((((((((###########(((//*/#@@@&&###################%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&&&&&&&&@@@@@@@@@@@@@@@@@@@@@&%*(@@@&##(//**************...&&@@@#@@@@@@@@@@@@@/%@&&&@@@@@@
    /// ((((((((((((((((((((((((((((((#########((//*((@@@&###################%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%*(@@@@@@@@@&&%#(/********,,.//@@@@@@@@@@@@@@@@@%&@&&&@@/@@@
    /// (((((((((((((((((((((((((((((((((((######(((((*//&@@&%##################%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*****,,...&@@@@@@@@@@@@@@@@@@@&&@@@@@@&
    /// ((((((((((((((((((((((((((((((((((((((######(((((/##@@@%%##################&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%##&&@@@@@@@@@@@@@@@%%&*****,,,..,**//((((((#%%%%%&@@@@@@@@@@@
    /// (((((((((((((((((((((((((((((((((((((((#######((((//#&@@&%###################&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%//*****/%%@@@@@@@@@@@@((#//*,,..,,,,,,,,,,..........,#@@@@**,,,*
    /// #######(((((((((((((((((((((((((((((((((((#######((((//%&@&&##################%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#(*..      ..***,(/@@@@@@@@@%%%,,,**********************##@@@@@@###***
    /// ################((((((((((((((((((((((((((((######((((((#&@@%###################@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%#/,.            ***,,(@@@@@@@@%%%*************************#%@@@@@@@@%**,
    /// ####################################((((((((((######((((((%%@&&##############%%&&&@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@%(,                ,***//@@@@@@&&%*********************************,,*&&@
    /// %%%%%%###############################################(((((((%@@&%######%%%%%%&&&&%%@@@@@@@@@@@@@@&&#%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@*,              .*****%&@@@@&&&******************************//#&&@%%%
    /// @@@@@@@@@@&&&&%%######################################(((((((&&@&&%%%&&&&&&&&%%#(((&&@@@@&&&&%%%#####%@@@@@@@@@@@@@@@@@@@@@@@@@@@@#(              .((%(((%@@@@&&%****************************(%@@@%%###%
    /// ..      ,,/##%@@@@@@@@@@@@@@@@&&&%%%################(##(((((#%%@@@&&&&&%##(((%&@@@@&&(((#%%&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#(              ,&&@@@&&&&&@&&&**********************//&@@@&%###%%&@@%
    /// @@@%#(/*..       .,**(%%&@@@@@@@@@@@@@@@@&&&&&%%%%#############&@@&&&%%(((%@@@@@&%(**,,,...  ...*//(#%%&&@@@@@@@@@@@@@@@@@@@@@@@@@#(            ..*&&@@@@&&&&@@@&*********************#@@@%%###%%&@@@##&
    /// ...,,//(##&@@@@@@@@@@@&&#//*,.           ..,//(%%&@@@@@@@@@@@@@@@@@@&@@@@@&//,..                               ..#&@@@%##@@@@@@@@@(/       .,******&&@%#,*/&&&%%&***************/%&@@@&##%%%%%%@@@@@@&&%
    /// ##(((((///****,,,****/(((((#%%&&&&&&%%###((/***,,......,,***/((%%&&&&##/,,                                        .,@@&%%@@@@@@@@@//   .,,****,,...&&@#(,/#&&@@@%##/*******/##&@@&&%%%%%%%%%%%%@&(%%&##&
    /// ###################(((//****,,.....,**(#%&@@@@@@@@@@@&%#(/**.                                                     ..@@&%%@@@@@@@@@** *****,..      &&@/* /&@@@@@@%%(/***/%%@@@&%##%%%%%%%%%%%%%@&#%%&%%@
    /// ####################################(((((//******,,,,****/((#%%&@@@@@@@@@@&&%#(/..                                 .@@@%%,@@@@@@@@(/,..            @@@#(***,,,,,(@@%&&@@@%%#%%@@@@@@@@@&&%%%%%%@&#%%&&&&
    /// ##############################################((((/////************//##%&&@@@@@@@@%,,                              .@@&&% //@@@@@@*,               @@@#(,..   ../@@&@@&%#%%&@@&###%@@@@@@%%%%%%@&#%%&&&&
    /// ####################################################################((((//////////(&&@%%.                          .@@&%%***/((#((                 ##@,.   .,%@@@@@@&&@@@%%(##&@@&&%&%*&&%%%%%%&&#&&&%%@