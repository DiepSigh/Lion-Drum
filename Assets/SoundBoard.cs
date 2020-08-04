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

    public AudioSource drumAudio;
    public AudioSource sideAudio;
    public Text recordText;
    public Text playText;

    bool recording;
    bool replaying;
    const int STORAGE = 200; //how many beats stored
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
            if(count != lastCount) {
                count++;
            }else{
                ReplayToggle();
            }
        }
    }

    public void PlayDrum(){
        drumAudio.Play();
        if(recording){
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
            nextBeatTime[count] = timestamp;
            beatType[count] = 1;
            count++;
            if (CountOver()){
                RecordToggle();
            }
        }
    }
    
    public void RecordToggle(){
        if(recording == false){
            count = 0;
            timestamp = 0;
            recording = true;
            recordText.text = "Recording";
        }else{
            timestamp = 0;
            lastCount = count;
            recording = false;
            recordText.text = "Record";
        }
    }

    public void ReplayToggle(){
        count = 0;
        timestamp = 0;
        if(replaying == false){
            replaying = true;
            playText.text = "Playing";
        }else{
            replaying = false;
            playText.text = "Play";
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
