//Scripted by Stephen Diep / DiepSigh
//Main functionality completed 08/02/2020
//Description:
//Plays lion dance drum beats, records and stores the sequence, then replays it.

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SoundBoard : MonoBehaviour
{

    public UIToggle UIManager;

    public AudioSource drumAudio;
    public AudioSource sideAudio;
    public AudioSource cymbalAudio;
    public AudioSource gongAudio;

    public Text recordText;
    public Text playText;

    bool recording;
    public bool replaying;
    bool recorded;
    const int STORAGE = 3000; //how many beats stored
    float[] _nextBeatTime = new float[STORAGE]; //stores when next beat is played
    int[] _beatType = new int[STORAGE]; //stores whether to play drum or side
    int count; //stores beat count; used for replay
    public int lastCount; //stores last recorded beat; last count of array
    float timestamp; //keeps track of current time

    public global::System.Single[] NextBeatTime {
        get => _nextBeatTime;
        set => _nextBeatTime = value;
    }
    public global::System.Int32[] BeatType {
        get => _beatType;
        set => _beatType = value; 
    }

    void Start(){
        timestamp = 0;
        lastCount = STORAGE;
        recording = false;
        replaying = false;
        recorded = false;
    }

    void Update(){
        if(recording){
            timestamp += Time.deltaTime;
        }

        if(replaying){
            timestamp += Time.deltaTime;
            PlayRecording();
        }
    }

    public void PlayRecording(){
        //If current updated timestamp goes over next beat count, play the recorded beat.
        if (timestamp >= NextBeatTime[count]){
            if (BeatType[count] == 0){
                PlayDrum();
            }else{
                PlaySide();
            }
            //If last beat hasn't been played, go to next count. Else, toggle replay.
            if(count+1 != lastCount) {
                count++;
            }else{
                ReplayToggle();
            }
        }
    }

    public void PlayDrum(){
        drumAudio.Play();
        if(recording){
            RecordedToggle();
            NextBeatTime[count] = timestamp;
            BeatType[count] = 0;
            count++;
            if (CountOver()){
                RecordToggle();
            }
        }
    }

    public void PlaySide(){
        sideAudio.Play();
        if(recording){
            RecordedToggle();
            NextBeatTime[count] = timestamp;
            BeatType[count] = 1;
            count++;
            if (CountOver()){
                RecordToggle();
            }
        }
    }

    void RecordedToggle(){
        if (recorded == false){
            recorded = true;
        }
    }

    public void PlayCymbals(){
        cymbalAudio.Play();
    }

    public void StopCymbals(){
        cymbalAudio.Stop();
    }

    public void PlayGong(){
        gongAudio.Play();
    }

    public void StopGong(){
        gongAudio.Stop();
    }
    
    public void RecordToggle(){
        if(recording == false){
            count = 0;
            timestamp = 0;
            recording = true;
            recordText.text = "Recording";
            UIManager.PlayOff();
            UIManager.InstrumentOff();
        }else{
            timestamp = 0;
            lastCount = count;
            recording = false;
            recordText.text = "Record";
            if (recorded) {
                UIManager.PlayOn();
            }
            UIManager.InstrumentOn();
        }
    }

    public void ReplayToggle(){
        count = 0;
        timestamp = 0;
        if(replaying == false){
            replaying = true;
            playText.text = "Playing";
            UIManager.RecordOff();
        }else{
            replaying = false;
            playText.text = "Play";
            if (UIManager.value == 0){
                UIManager.RecordOn();
            }
        }
    }

    //checks if count will go over array count
    bool CountOver(){
        if(count >= STORAGE-1){
            return true;
        }else{
            return false;
        }
    }
}
