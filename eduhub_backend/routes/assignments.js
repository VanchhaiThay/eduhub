const express = require('express');
const pool = require('../config/database');

const router = express.Router();

// Create new assignment
router.post('/', async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const { title, language, questions } = req.body;

    // Validate required fields
    if (!title || !language || !questions || !Array.isArray(questions) || questions.length === 0) {
      return res.status(400).json({ 
        error: 'Title, language, and at least one question are required' 
      });
    }

    // Insert assignment
    const assignmentQuery = `
      INSERT INTO assignments (title, language)
      VALUES ($1, $2)
      RETURNING id, title, language, created_at, updated_at
    `;
    const assignmentResult = await client.query(assignmentQuery, [title, language]);
    const assignment = assignmentResult.rows[0];

    // Insert questions
    const insertedQuestions = [];
    for (let i = 0; i < questions.length; i++) {
      const question = questions[i];
      
      // Validate question fields
      if (!question.question_text || !question.type) {
        await client.query('ROLLBACK');
        return res.status(400).json({ 
          error: `Question ${i + 1}: question_text and type are required` 
        });
      }

      const questionQuery = `
        INSERT INTO questions (assignment_id, question_text, type, image_url, correct_answer, points)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id, assignment_id, question_text, type, image_url, correct_answer, points, created_at
      `;
      
      const questionValues = [
        assignment.id,
        question.question_text,
        question.type,
        question.image_url || null,
        question.correct_answer || null,
        question.points || 1
      ];
      
      const questionResult = await client.query(questionQuery, questionValues);
      const insertedQuestion = questionResult.rows[0];

      // Insert options for multiple choice questions
      if (question.type === 'Multiple Choice' && question.options && Array.isArray(question.options)) {
        const insertedOptions = [];
        
        for (let j = 0; j < question.options.length; j++) {
          const optionQuery = `
            INSERT INTO question_options (question_id, option_text, option_order)
            VALUES ($1, $2, $3)
            RETURNING id, question_id, option_text, option_order, created_at
          `;
          
          const optionResult = await client.query(optionQuery, [
            insertedQuestion.id,
            question.options[j],
            j + 1
          ]);
          
          insertedOptions.push(optionResult.rows[0]);
        }
        
        insertedQuestion.options = insertedOptions;
      }
      
      insertedQuestions.push(insertedQuestion);
    }

    await client.query('COMMIT');

    // Log successful creation to terminal
    console.log('✅ ASSIGNMENT CREATED SUCCESSFULLY');
    console.log('=====================================');
    console.log(`Assignment ID: ${assignment.id}`);
    console.log(`Title: ${assignment.title}`);
    console.log(`Language: ${assignment.language}`);
    console.log(`Questions: ${insertedQuestions.length}`);
    console.log(`Created At: ${assignment.created_at}`);
    console.log('=====================================');

    res.status(201).json({
      message: 'Assignment created successfully',
      assignment: {
        ...assignment,
        questions: insertedQuestions
      }
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Create assignment error:', error.message);
    res.status(500).json({ error: 'Failed to create assignment' });
  } finally {
    client.release();
  }
});

// Get all assignments
router.get('/', async (req, res) => {
  try {
    const query = `
      SELECT a.id, a.title, a.language, a.created_at, a.updated_at,
             COUNT(q.id) as question_count
      FROM assignments a
      LEFT JOIN questions q ON a.id = q.assignment_id
      GROUP BY a.id, a.title, a.language, a.created_at, a.updated_at
      ORDER BY a.created_at DESC
    `;
    
    const result = await pool.query(query);
    res.json(result.rows);
  } catch (error) {
    console.error('Get assignments error:', error.message);
    res.status(500).json({ error: 'Failed to get assignments' });
  }
});

// Get assignment by ID with questions and options
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get assignment
    const assignmentQuery = 'SELECT * FROM assignments WHERE id = $1';
    const assignmentResult = await pool.query(assignmentQuery, [id]);
    
    if (assignmentResult.rows.length === 0) {
      return res.status(404).json({ error: 'Assignment not found' });
    }
    
    const assignment = assignmentResult.rows[0];
    
    // Get questions with options
    const questionsQuery = `
      SELECT q.id, q.question_text, q.type, q.image_url, q.correct_answer, q.points, q.created_at,
             json_agg(
               json_build_object(
                 'id', o.id,
                 'option_text', o.option_text,
                 'option_order', o.option_order
               ) ORDER BY o.option_order
             ) as options
      FROM questions q
      LEFT JOIN question_options o ON q.id = o.question_id
      WHERE q.assignment_id = $1
      GROUP BY q.id, q.question_text, q.type, q.image_url, q.correct_answer, q.points, q.created_at
      ORDER BY q.id
    `;
    
    const questionsResult = await pool.query(questionsQuery, [id]);
    assignment.questions = questionsResult.rows;
    
    res.json(assignment);
  } catch (error) {
    console.error('Get assignment error:', error.message);
    res.status(500).json({ error: 'Failed to get assignment' });
  }
});

// Delete assignment
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const deleteQuery = 'DELETE FROM assignments WHERE id = $1 RETURNING *';
    const result = await pool.query(deleteQuery, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Assignment not found' });
    }
    
    console.log(`✅ Assignment ${id} deleted successfully`);
    
    res.json({
      message: 'Assignment deleted successfully',
      assignment: result.rows[0]
    });
  } catch (error) {
    console.error('Delete assignment error:', error.message);
    res.status(500).json({ error: 'Failed to delete assignment' });
  }
});

module.exports = router;
