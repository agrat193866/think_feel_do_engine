# This migration comes from think_feel_do_engine (originally 20140730202349)
class UpdateThoughtPatterns < ActiveRecord::Migration
  def up
    [
      {
        old_title: "All-or-Nothing (Black-or-White) Thinking",
        new_title: "Absolute",
        description: "Thinking in extremes, all good or all bad, the best or the worst, perfect or a failure.",
        recommendations: "
          <p>Try to engage in more balanced thinking.<p>
          <p>Are there shades of gray?</p>
          <p>Remember that things are usually somewhere between 0 and 100 percent and not one way or the other.</p>"
      },{
        old_title: "Fortune Telling",
        new_title: "Guesses",
        description: "Making guesses or jumping to conclusions that are overly negative. E.g., thinking you know what others are thinking (and it’s bad).",
        recommendations: "
          <p>Can we really know what others are thinking?</p>
          <p>What are possible alternatives to why they might be behaving the way they are behaving?</p>
          <p>Can we really predict the future?</p>
          <p>What would it be like to find out how it really is rather than just imagine it?</p>"
      },{
        old_title: "Mental Filter",
        new_title: "Tunnel Vision",
        description: "Seeing only the things that confirm your negative view while ignoring positive experiences.",
        recommendations: "
          <p>Try to catch the positive.</p>
          <p>What are some positive things that discount your thought?</p>"
      },{
        old_title: "Magnification or Catastrophizing",
        new_title: "Magnifying or Minimizing",
        description: "Blowing the importance or consequences of negative things out of proportion or shrinking the significance of positive things.",
        recommendations: "
          <p>How big is this problem really?</p>
          <p>Where is it likely to really lead?</p>
          <p>Are you overlooking your strengths and accomplishments?</p>"
      },{
        old_title: "Labeling and Mislabeling",
        new_title: "Labeling",
        description: "Attaching a negative label, instead of seeing an error or problem.",
        recommendations: "
          <p>What is it specifically that I can’t do or that I am upset about.</p>
          <p>What I did in this situation does not define who I am.</p>
          <p>Remember: What did I do vs. who am I?</p>"
      },{
        old_title: "Overgeneralization",
        new_title: "Overgeneralization",
        description: "Taking a characteristic or event and seeing it as a never ending pattern.",
        recommendations: "
          <p>Am I assuming that every situation and every person are the same?</p>
          <p>This is just one situation, one person.</p>"
      },{
        old_title: "Personalization",
        new_title: "Personalization",
        description: "Taking responsibility for things you can’t control.",
        recommendations: "
          <p>Am I to blame for everything always?</p>
          <p>Do only bad things happen to me?</p>
          <p>Remember the good that has happened to me and that I have created.</p>"
      },{
        old_title: "\"Should\" Statements",
        new_title: "\"Should\"ing Yourself",
        description: "Taking responsibility for things you can’t control.",
        recommendations: "
          <p>Replace “should” statements with more accurate statements.</p>
          <p>It would be preferable, it would be nice, but it is not necessary.</p>
          <p>I do not have to do anything and things do not have to turn out the way I want.</p>"        
      }
    ].each do |thought_pattern|
      tp = ThoughtPattern.find_by_title(thought_pattern[:old_title])
      puts "thought_pattern = #{thought_pattern[:old_title]}"
      if tp
        tp.update_attributes(
          title: thought_pattern[:new_title],
          description: thought_pattern[:description],
          recommendations: thought_pattern[:recommendations]
        )
        tp.save!
        puts "ThoughtPattern with title was updated!"
      else
        puts "ThoughtPattern with title '#{thought_pattern[:old_title]}' doesn't exist!"
      end
    end
    ["Emotional Reasoning", "Minimization", "Discounting the Positive"].each do |thought_pattern|
      puts "thought_pattern = #{thought_pattern}"
      tp = ThoughtPattern.find_by_title(thought_pattern)
      if tp
        tp.destroy
        puts "Destroyed ThoughtPattern with title #{thought_pattern}"
      else
        puts "ThoughtPattern with title #{thought_pattern} doesn't exist!"
      end
    end
  end
end