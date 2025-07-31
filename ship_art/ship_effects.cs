using Godot;
using System;

public partial class ship_effects : Node
{	
	[Export]
	public Material offMat;
	[Export]
	public Material onMat;
	[Export] 
	public float min_FOV = 55.0f;
	[Export] 
	public float max_FOV = 90.0f;
	[Export]
	public float min_effect_speed = 0.0f;
	[Export]
	public float max_effect_speed = 90.0f;
	[Export]
	public float maxSpeedScale = 8.0f;
	public float effect_rate = 2.0f;
	
	// No longer [Export] public, just look for it in _Ready()
	private Camera3D cam = null;
	private float current_FOV = 75.0f;
	private AnimationPlayer _animator;
	private float speedScale = 1.0f;
	private float minSpeedScale = 0.2f;
	//4private float maxSpeedScale = 10.0f;
	private float speed = 1.0f;
	// For tracking speed, instead of using inputs:
	// TODO: make this ^^ globally availabl, since there are likely a number of things that could depend on it.
	private float cur_speed = 0.0f;
	private Vector3 cur_pos;
	private Vector3 pos_last_frame;
	private float dist_moved = 0;
	// How about we add some averaging...
	private float average_speed = 0;
	private float[] prev_speeds = new float[24];
	private int index = 0;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		_animator = ((AnimationPlayer) GetNode("AnimationPlayer"));
		_animator.Play("shake_ship");
		cam = GetNode<Camera3D>("../Camera3D");
		if(cam != null){
			cam.Fov = current_FOV;
		}
		else{
			GD.Print("Why camera null?");
		}
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		cur_pos = GetParent<Node3D>().GlobalPosition;
		//GD.Print(GetParent<Node3D>().GlobalPosition);
		 //if (Input.IsActionPressed("gas"))
		//{
			//// Speed up shake on move up:
			//speedScale += speed * (float) delta * effect_rate;
			//current_FOV -= (float) delta * effect_rate;
		//}
		//
		//if (Input.IsActionPressed("brake"))
		//{
			//// Slow down shake on move up:
			//speedScale -= speed * (float)delta * effect_rate;
			//current_FOV += (float) delta * effect_rate;
		//}
		
		// Calc distance moved this frame:
		dist_moved = pos_last_frame.DistanceTo(cur_pos);
		cur_speed = dist_moved / (float) delta;
		prev_speeds[index] = cur_speed;
		average_speed = 0;
		foreach (float speed in prev_speeds){
			average_speed += speed;
		}
		average_speed /= prev_speeds.Length;
		// GD.Print(average_speed);
		float by = average_speed/max_effect_speed;  // The Godot docs use the word "by"
		speedScale = Mathf.Lerp(minSpeedScale, maxSpeedScale, by);
		current_FOV = Mathf.Lerp(max_FOV, min_FOV, by);
		
		if(speedScale > maxSpeedScale) speedScale = maxSpeedScale;
		else if(speedScale < 0) speedScale = 0;
		if(current_FOV > max_FOV) current_FOV = max_FOV;
		else if(current_FOV < min_FOV) current_FOV = min_FOV;
		_animator.SpeedScale = speedScale;
		if(cam != null){
			cam.Fov = current_FOV;
			//GD.Print("FOV set to: " + cam.Fov);
		}
		// Lastly, update pos_last_frame:
		index += 1;
		index %= prev_speeds.Length;
		prev_speeds[index] = cur_speed;
		pos_last_frame = cur_pos;
	}
	
}
