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
    float[] nextBeatTime = new float[STORAGE]; //stores when next beat is played
    int[] beatType = new int[STORAGE]; //stores whether to play drum or side
    int count; //stores beat count
    int lastCount; //stores last recorded beat
    float timestamp; //keeps track of current time
    
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
        if (timestamp >= nextBeatTime[count]){
            if (beatType[count] == 0){
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
            nextBeatTime[count] = timestamp;
            beatType[count] = 0;
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
            nextBeatTime[count] = timestamp;
            beatType[count] = 1;
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
